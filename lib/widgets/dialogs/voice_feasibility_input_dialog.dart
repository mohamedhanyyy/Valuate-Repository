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
  Timer? _recordTimer;
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
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initSpeechRecognition();
  }

  Future<void> _initSpeechRecognition() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (err) {
          debugPrint('STT Error: ${err.errorMsg}');
          if (mounted && _isRecording) {
            _stopRecording();
          }
        },
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isRecording) {
              _stopRecording();
            }
          }
        },
      );
      if (mounted) setState(() {});
    } catch (_) {
      _speechEnabled = false;
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
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

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
      _emptyNotice = null;
      _parseResult = null;
    });

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

    if (_speechEnabled) {
      try {
        final isArabic = widget.locale == 'ar';
        final systemLocales = await _speechToText.locales();
        String targetLocale = isArabic ? 'ar_SA' : 'en_US';

        for (final loc in systemLocales) {
          if (isArabic && loc.localeId.toLowerCase().startsWith('ar')) {
            targetLocale = loc.localeId;
            break;
          } else if (!isArabic && loc.localeId.toLowerCase().startsWith('en')) {
            targetLocale = loc.localeId;
            break;
          }
        }

        await _speechToText.listen(
          listenOptions: stt.SpeechListenOptions(
            localeId: targetLocale,
            listenMode: stt.ListenMode.dictation,
            partialResults: true,
          ),
          onResult: (result) {
            if (mounted) {
              setState(() {
                _transcriptController.text = result.recognizedWords;
              });
              if (result.recognizedWords.isNotEmpty) {
                _runAnalysis();
              }
            }
          },
        );
      } catch (e) {
        debugPrint('Listen error: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isRecording = false;
      });

      final text = _transcriptController.text.trim();
      if (text.isEmpty) {
        setState(() {
          _emptyNotice = widget.locale == 'ar'
              ? 'لم يتم التقاط صوت واضح. يمكنك الضغط على المايك مرة أخرى أو كتابة تفاصيل مشروعك أو اختيار نموذج جاهز للتجربة.'
              : 'No speech recognized. Tap mic again, type details, or choose a sample prompt.';
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

    Future.delayed(const Duration(milliseconds: 250), () {
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
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        'AI NLP',
                        style: const TextStyle(
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
            const SizedBox(height: 20),

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
                        width: 72,
                        height: 72,
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
                                  .withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 34,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _isRecording
                          ? AppColors.danger
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                    ),
                  ),

                  // Simulated Waveform Bars
                  if (_isRecording) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(16, (i) {
                        final heights = [10, 18, 28, 14, 32, 22, 12, 30, 24, 16, 28, 20, 12, 26, 18, 10];
                        return Container(
                          width: 3.5,
                          height: heights[i].toDouble(),
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
                    const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _emptyNotice!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFFFD580) : const Color(0xFF92400E),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Pre-built Quick Voice Samples
            Text(
              isArabic ? 'أو اختر نموذجاً صوتياً جاهزاً للتجربة:' : 'Or test a sample voice prompt:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
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
                        avatar: const Icon(Icons.play_circle_outline_rounded, size: 16, color: AppColors.gold),
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

            // Transcript Box
            Text(
              isArabic ? 'النص الصوتي المفرّغ (يمكنك التعديل عليه):' : 'Speech Transcript (Editable):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
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
