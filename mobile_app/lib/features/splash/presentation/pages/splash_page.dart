import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _ornamentFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.45, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.50, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.38, 0.72, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.38, 0.72, curve: Curves.easeOut),
    ));
    _ornamentFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.62, 1.00, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Logo ──────────────────────────────────────────────────────
            ScaleTransition(
              scale: _logoScale,
              child: FadeTransition(
                opacity: _logoFade,
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppTheme.accent, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withAlpha(70),
                        blurRadius: 28,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── App name ──────────────────────────────────────────────────
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Antologiya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Ornamental divider ─────────────────────────────
                    FadeTransition(
                      opacity: _ornamentFade,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 1,
                            color: AppTheme.accent.withAlpha(160),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 48,
                            height: 1,
                            color: AppTheme.accent.withAlpha(160),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Tagline ────────────────────────────────────────
                    FadeTransition(
                      opacity: _ornamentFade,
                      child: Text(
                        'app_name'.tr(),
                        style: TextStyle(
                          color: AppTheme.accent.withAlpha(200),
                          fontSize: 12,
                          letterSpacing: 0.8,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
