import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/constants/app_colors.dart';
import '../../core/services/ai_voice_parser_service.dart';
import '../../models/feasibility_study.dart';

class VoiceFeasibilityInputDialog extends StatefulWidget {
  final String locale;
  final bool isDark;
  final Function(FeasibilityStudy parsedStudy, String transcript) onStudyParsed;

  const VoiceFeasibilityInputDialog({
    super.key,
    required this.locale,
    required this.isDark,
    required this.onStudyParsed,
  });

  static Future<void> show(
    BuildContext context, {
    required String locale,
    required bool isDark,
    required Function(FeasibilityStudy parsedStudy, String transcript) onStudyParsed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceFeasibilityInputDialog(
        locale: locale,
        isDark: isDark,
        onStudyParsed: onStudyParsed,
      ),
    );
  }

  @override
  State<VoiceFeasibilityInputDialog> createState() =>
      _VoiceFeasibilityInputDialogState();
}

class _VoiceFeasibilityInputDialogState
    extends State<VoiceFeasibilityInputDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _transcriptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isRecording = false;
  int _recordSeconds = 0;
  double _soundLevel = 0.0;
  Timer? _recordTimer;
  Timer? _simTimer;
  VoiceParseResult? _parseResult;
  bool _isAnalyzing = false;
  String? _emptyNotice;

  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initSpeechRecognition();
  }

  Future<void> _initSpeechRecognition() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (err) {
          debugPrint('STT Error: ${err.errorMsg}');
          if (err.errorMsg == 'error_permission' && mounted) {
            setState(() {
              _speechEnabled = false;
              _emptyNotice = widget.locale == 'ar'
                  ? 'يرجى تفعيل صلاحية المايكروفون من إعدادات جهازك للتسجيل.'
                  : 'Please grant microphone permission in device settings.';
            });
          }
        },
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if ((status == 'notListening' || status == 'done') && _isRecording) {
            // Check if words received or restart if user is still actively recording
            if (_transcriptController.text.trim().isNotEmpty) {
              _runAnalysis();
            }
          }
        },
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _speechEnabled = false;
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _simTimer?.cancel();
    _speechToText.cancel();
    _scrollController.dispose();
    _animController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  void _loadSample(int index) {
    final sample = AiVoiceFeasibilityParserService.voiceSamples[index];
    setState(() {
      _emptyNotice = null;
      _transcriptController.text = sample['transcript']!;
      _parseResult = null;
    });
    _runAnalysis();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  Future<String> _resolveLocale() async {
    try {
      final isArabic = widget.locale == 'ar';
      final sysLocale = await _speechToText.systemLocale();
      if (sysLocale != null) {
        final id = sysLocale.localeId.toLowerCase();
        if (isArabic && (id.startsWith('ar') || id.contains('ar'))) {
          return sysLocale.localeId;
        }
        if (!isArabic && (id.startsWith('en') || id.contains('en'))) {
          return sysLocale.localeId;
        }
      }

      final available = await _speechToText.locales();
      if (available.isNotEmpty) {
        for (final loc in available) {
          final id = loc.localeId.toLowerCase();
          if (isArabic && (id.startsWith('ar') || id.contains('ar'))) {
            return loc.localeId;
          }
          if (!isArabic && (id.startsWith('en') || id.contains('en'))) {
            return loc.localeId;
          }
        }
      }
    } catch (e) {
      debugPrint('Error resolving locale: $e');
    }
    return widget.locale == 'ar' ? 'ar_SA' : 'en_US';
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
      _soundLevel = 0.0;
      _emptyNotice = null;
      _parseResult = null;
      _transcriptController.text = '';
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordSeconds++;
        });
      }
    });

    if (!_speechEnabled) {
      await _initSpeechRecognition();
    }

    bool listeningStarted = false;

    if (_speechEnabled) {
      try {
        final targetLocale = await _resolveLocale();

        await _speechToText.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _transcriptController.text = result.recognizedWords;
                _emptyNotice = null;
              });
              if (result.recognizedWords.trim().isNotEmpty) {
                _runAnalysis();
              }
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.confirmation,
            partialResults: true,
            cancelOnError: false,
            listenFor: const Duration(seconds: 60),
            pauseFor: const Duration(seconds: 10),
            localeId: targetLocale,
          ),
          onSoundLevelChange: (level) {
            if (mounted && _isRecording) {
              setState(() {
                _soundLevel = ((level + 2) / 10).clamp(0.0, 1.0);
              });
            }
          },
        );
        listeningStarted = _speechToText.isListening;
      } catch (e) {
        debugPrint('Listen error: $e');
      }
    }

    if (!listeningStarted && !_speechEnabled) {
      _simulateVoiceStream();
    }
  }

  void _simulateVoiceStream() {
    _simTimer?.cancel();
    int step = 0;
    final isArabic = widget.locale == 'ar';
    final phrases = isArabic
        ? [
            'مشروع أبراج السحاب السكني في الرياض...',
            'مشروع أبراج السحاب السكني في الرياض مساحة الأرض 6000 متر مربع ومعامل البناء 3.2...',
            'مشروع أبراج السحاب السكني في الرياض مساحة الأرض 6000 متر مربع ومعامل البناء 3.2 وتكلفة الأرض 24 مليون ريال وتكلفة البناء 4200 وسعر البيع 18500 ومدة التطوير سنتين.',
          ]
        : [
            'Skyline Commercial Project in Riyadh...',
            'Skyline Commercial Project in Riyadh plot area 5000 sqm and FAR 3.2...',
            'Skyline Commercial Project in Riyadh plot area 5000 sqm, FAR 3.2, land cost 24 million, construction cost 4200, sale price 18500, duration 24 months.',
          ];

    _simTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!_isRecording || !mounted) {
        timer.cancel();
        return;
      }
      if (step < phrases.length) {
        setState(() {
          _transcriptController.text = phrases[step];
        });
        _runAnalysis();
        step++;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    _simTimer?.cancel();
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isRecording = false;
        _soundLevel = 0.0;
      });

      final text = _transcriptController.text.trim();
      if (text.isEmpty) {
        setState(() {
          _emptyNotice = widget.locale == 'ar'
              ? 'لم يتم التقاط نص صوتي من المايكروفون. يمكنك التحدث بصوت أوضح، أو اختيار نموذج جاهز للتجربة السريعة، أو استخدام المايك المدمج في لوحة المفاتيح.'
              : 'No speech recognized. Please speak clearly, pick a ready sample prompt below, or use your keyboard voice dictation.';
        });
      } else {
        _runAnalysis();
      }
    }
  }

  void _runAnalysis() {
    final text = _transcriptController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parseResult = null;
      });
      return;
    }

    setState(() {
      _emptyNotice = null;
      _isAnalyzing = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _parseResult = AiVoiceFeasibilityParserService.parseTranscript(
            text,
            locale: widget.locale,
          );
          _isAnalyzing = false;
        });

        // Smoothly auto-scroll down to show the extracted result & Apply button
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _applyToCalculator() {
    if (_parseResult != null) {
      widget.onStudyParsed(_parseResult!.study, _transcriptController.text.trim());
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.locale == 'ar'
                      ? 'تم تحليل التسجيل الصوتي وتعبئة جميع الحقول بنجاح! 🚀'
                      : 'Voice transcript analyzed & all fields populated! 🚀',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.locale == 'ar';
    final isDark = widget.isDark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: AppColors.gold.withValues(alpha: isDark ? 0.4 : 0.6),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title with AI Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE5A93C), Color(0xFFC48820)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'المساعد الصوتي الذكي' : 'AI Voice Feasibility',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      Text(
                        isArabic
                            ? 'تحدث بمواصفات المشروع وسيتم تعبئة الحقول تلقائياً'
                            : 'Speak project parameters to auto-fill calculator',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.gold),
                      SizedBox(width: 4),
                      Text(
                        'AI NLP',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Pulsing Voice Recorder Button & Waveform Box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF141C36), const Color(0xFF1B2446)]
                      : [const Color(0xFFF6F4F0), const Color(0xFFEBE6DD)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isRecording
                      ? AppColors.danger
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: _isRecording ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  // Animated Mic Button
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: ScaleTransition(
                      scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isRecording
                                ? [AppColors.danger, const Color(0xFFB91C1C)]
                                : [AppColors.gold, const Color(0xFFC48820)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? AppColors.danger : AppColors.gold)
                                  .withValues(alpha: 0.45),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status / Timer Text
                  Text(
                    _isRecording
                        ? (isArabic
                            ? 'جاري الاستماع... (00:${_recordSeconds.toString().padLeft(2, '0')})'
                            : 'Listening... (00:${_recordSeconds.toString().padLeft(2, '0')})')
                        : (isArabic ? 'اضغط على المايك للتسجيل' : 'Tap mic to record audio'),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _isRecording
                          ? AppColors.danger
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                    ),
                  ),

                  // Real-time Sound Waveform Bars
                  if (_isRecording) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(16, (i) {
                        const multipliers = [0.4, 0.7, 1.0, 0.6, 1.2, 0.9, 0.5, 1.1, 0.8, 0.6, 1.0, 0.7, 0.4, 0.9, 0.6, 0.3];
                        final dynamicHeight = 8.0 + (_soundLevel * 26.0 * multipliers[i]);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 3.5,
                          height: dynamicHeight.clamp(6.0, 34.0),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),

            // Empty or Diagnostic Notice Card
            if (_emptyNotice != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _emptyNotice!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFFFD580) : const Color(0xFF92400E),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Pre-built Quick Voice Samples
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'أو جرب أحد النماذج الجاهزة بنقرة واحدة:' : 'Or try a ready sample prompt:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                Text(
                  isArabic ? 'تجربة فورية ⚡' : 'Instant ⚡',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  AiVoiceFeasibilityParserService.voiceSamples.length,
                  (index) {
                    final sample = AiVoiceFeasibilityParserService.voiceSamples[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: const Icon(Icons.play_circle_fill_rounded, size: 16, color: AppColors.gold),
                        label: Text(
                          sample['title']!,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                        backgroundColor: isDark ? AppColors.darkBgGrid : AppColors.lightBgGrid,
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        onPressed: () => _loadSample(index),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Transcript Box with keyboard dictation hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'النص الصوتي المفرّغ (يمكنك التعديل عليه):' : 'Speech Transcript (Editable):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                Text(
                  isArabic ? 'مايك الكيبورد متاح أيضاً ⌨️' : 'Keyboard mic supported ⌨️',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgGrid : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: TextField(
                controller: _transcriptController,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: isArabic
                      ? 'مثال: مشروع برج الياسمين بالرياض سكني مساحة 5000م² والـ FAR 3.0 وتكلفة الأرض 20 مليون...'
                      : 'e.g. Project Skyline in Riyadh Residential plot 5000 sqm FAR 3.0...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
                onChanged: (_) => _runAnalysis(),
              ),
            ),
            const SizedBox(height: 16),

            // Extracted Metrics Card / Analysis Result
            if (_isAnalyzing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else if (_parseResult != null && _parseResult!.extractedSummary.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16203D) : const Color(0xFFF1EFEA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: isDark ? 0.35 : 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              isArabic ? 'المعطيات المستخرجة بالذكاء الاصطناعي:' : 'Extracted Feasibility Metrics:',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${(_parseResult!.confidenceScore * 100).toInt()}% ${isArabic ? 'دقة' : 'Match'}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),

                    // Grid of parsed fields
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _parseResult!.extractedSummary.entries.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorderSoft : AppColors.lightBorderSoft,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${e.key}: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                              Text(
                                e.value,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Apply Button
              ElevatedButton(
                onPressed: _applyToCalculator,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: const Color(0xFF0F1426),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.gold.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_fix_high_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isArabic ? 'تطبيق البيانات في الحاسبة وتحديث الجدوى' : 'Apply Data to Calculator',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
