import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class AppSnackBar {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static _ActiveSnackBar? _activeSnackBar;

  /// Show custom animated top snackbar
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(milliseconds: 3500),
    VoidCallback? onTap,
    IconData? customIcon,
  }) {
    // If an existing snackbar is showing, dismiss it first
    _activeSnackBar?.dismiss();

    final overlayState = Overlay.maybeOf(context, rootOverlay: true) ??
        navigatorKey.currentState?.overlay;

    if (overlayState == null) return;

    late final OverlayEntry overlayEntry;
    late final _ActiveSnackBar activeSnackBar;

    overlayEntry = OverlayEntry(
      builder: (ctx) => _TopSnackBarWidget(
        message: message,
        title: title,
        type: type,
        duration: duration,
        customIcon: customIcon,
        onTap: onTap,
        onDismissed: () {
          if (_activeSnackBar == activeSnackBar) {
            _activeSnackBar = null;
          }
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
        onRegisterDismiss: (dismissFn) {
          activeSnackBar.dismissFn = dismissFn;
        },
      ),
    );

    activeSnackBar = _ActiveSnackBar(
      entry: overlayEntry,
      dismissFn: () {},
    );
    _activeSnackBar = activeSnackBar;

    overlayState.insert(overlayEntry);
  }

  /// Convenience helper for success notification
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  /// Convenience helper for error notification
  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 4000),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  /// Convenience helper for warning notification
  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  /// Convenience helper for info notification
  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackBarType.info,
      duration: duration,
    );
  }
}

class _ActiveSnackBar {
  final OverlayEntry entry;
  VoidCallback dismissFn;

  _ActiveSnackBar({
    required this.entry,
    required this.dismissFn,
  });

  void dismiss() {
    dismissFn();
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final String? title;
  final SnackBarType type;
  final Duration duration;
  final IconData? customIcon;
  final VoidCallback? onTap;
  final VoidCallback onDismissed;
  final void Function(VoidCallback dismissFn) onRegisterDismiss;

  const _TopSnackBarWidget({
    required this.message,
    this.title,
    required this.type,
    required this.duration,
    this.customIcon,
    this.onTap,
    required this.onDismissed,
    required this.onRegisterDismiss,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _progressController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  bool _isDismissed = false;
  double _dragOffsetY = 0.0;

  @override
  void initState() {
    super.initState();

    widget.onRegisterDismiss(_dismiss);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      reverseDuration: const Duration(milliseconds: 320),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _animController.forward();
    _progressController.forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (_isDismissed || !mounted) return;
    _isDismissed = true;
    _progressController.stop();
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Color _getAccentColor() {
    switch (widget.type) {
      case SnackBarType.success:
        return const Color(0xFF10B981);
      case SnackBarType.error:
        return const Color(0xFFEF4444);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B);
      case SnackBarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getDefaultIcon() {
    if (widget.customIcon != null) return widget.customIcon!;
    switch (widget.type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_outline_rounded;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
      case SnackBarType.info:
        return Icons.info_outline_rounded;
    }
  }

  String _getDefaultTitle(bool isArabic) {
    if (widget.title != null && widget.title!.isNotEmpty) {
      return widget.title!;
    }
    switch (widget.type) {
      case SnackBarType.success:
        return isArabic ? 'نجاح' : 'Success';
      case SnackBarType.error:
        return isArabic ? 'خطأ' : 'Error';
      case SnackBarType.warning:
        return isArabic ? 'تنبيه' : 'Warning';
      case SnackBarType.info:
        return isArabic ? 'إشعار' : 'Notice';
    }
  }

  bool _isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = mediaQuery.padding.top;
    final accentColor = _getAccentColor();
    final isArabic = _isArabicText(widget.message);

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final slideValue = (1.0 - _slideAnimation.value) * -100;
            return Transform.translate(
              offset: Offset(0, slideValue + _dragOffsetY),
              child: Opacity(
                opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
            );
          },
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null) {
                setState(() {
                  _dragOffsetY += details.primaryDelta!;
                  if (_dragOffsetY > 15) _dragOffsetY = 15; // Resistance downwards
                });
                if (_dragOffsetY < -25) {
                  _dismiss();
                }
              }
            },
            onVerticalDragEnd: (details) {
              if (_dragOffsetY < -15 || (details.primaryVelocity ?? 0) < -200) {
                _dismiss();
              } else {
                setState(() => _dragOffsetY = 0.0);
              }
            },
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!();
              }
              _dismiss();
            },
            child: Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xEB131B32)
                              : Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: accentColor.withValues(alpha: isDark ? 0.38 : 0.45),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: isDark ? 0.22 : 0.15),
                              blurRadius: 22,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Animated Glow Icon Avatar
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          accentColor.withValues(alpha: 0.25),
                                          accentColor.withValues(alpha: 0.08),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: accentColor.withValues(alpha: 0.45),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getDefaultIcon(),
                                        color: accentColor,
                                        size: 21,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Text Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _getDefaultTitle(isArabic),
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: accentColor,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          widget.message,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                            height: 1.35,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Close Button
                                  InkWell(
                                    onTap: _dismiss,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.06)
                                            : Colors.black.withValues(alpha: 0.04),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: isDark
                                            ? AppColors.darkTextFaint
                                            : AppColors.lightTextFaint,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Smooth Animated Progress Bar at Bottom
                            AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, _) {
                                final remaining = (1.0 - _progressController.value).clamp(0.0, 1.0);
                                return Container(
                                  height: 2.5,
                                  width: double.infinity,
                                  color: accentColor.withValues(alpha: 0.12),
                                  alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: remaining,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            accentColor,
                                            accentColor.withValues(alpha: 0.8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
