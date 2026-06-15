
import 'package:flutter/material.dart';
import 'package:application_belajar/widgets/mascot_painter.dart';

/// MindMate Splash Screen with multi-phase animation.
///
/// Animation sequence (matching the design):
/// Phase 1 (0.00–0.10): Purple bg, kawaii face appears (eyes open + cheeks)
/// Phase 2 (0.10–0.20): Face winks (right eye wink animation)
/// Phase 3 (0.20–0.30): Face blinks (both eyes close briefly)
/// Phase 4 (0.30–0.40): Face shrinks down to small size
/// Phase 5 (0.40–0.55): Full mascot appears in white circle on purple bg
/// Phase 6 (0.55–0.75): Background transitions purple → soft pink, circle fades
/// Phase 7 (0.75–1.00): Mascot stays, "MindMate" text fades in below
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Main timeline controller (drives all phases)
  late AnimationController _mainController;

  // Blink animation for the kawaii face
  late AnimationController _blinkController;

  // Bounce animation for the mascot
  late AnimationController _bounceController;

  // Phase-specific animations
  late Animation<double> _faceOpacity;
  late Animation<double> _faceScale;
  late Animation<double> _faceShrink;
  late Animation<double> _winkProgress;
  late Animation<double> _blinkProgress;
  late Animation<double> _mascotOpacity;
  late Animation<double> _mascotScale;
  late Animation<double> _circleScale;
  late Animation<double> _circleOpacity;
  late Animation<double> _bgColorProgress;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _bounceAnim;

  // Colors
  static const _purpleBg = Color(0xFFB39DDB);
  static const _softPinkBg = Color(0xFFF3E5F5);
  static const _circleWhite = Color(0xFFF3E5F5);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    // Main timeline: 5 seconds total
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    // Subtle bounce loop for mascot
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Blink controller for repeated blinks
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // ── Phase 1: Face appears (0.00 → 0.10) ──
    _faceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.08, curve: Curves.easeOut),
      ),
    );
    _faceScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.10, curve: Curves.elasticOut),
      ),
    );

    // ── Phase 2: Wink (0.12 → 0.22) ──
    _winkProgress = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 3),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 4),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 3),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 78),
    ]).animate(_mainController);

    // ── Phase 3: Blink (0.24 → 0.30) ──
    _blinkProgress = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 24),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 70),
    ]).animate(_mainController);

    // ── Phase 4: Face shrinks (0.32 → 0.42) ──
    _faceShrink = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 32),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 58),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.linear));

    // ── Phase 5: Mascot appears in circle (0.42 → 0.56) ──
    _mascotOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.42, 0.50, curve: Curves.easeOut),
      ),
    );
    _mascotScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.42, 0.55, curve: Curves.elasticOut),
      ),
    );
    _circleScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 13),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.linear));
    _circleOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 17),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 25),
    ]).animate(_mainController);

    // ── Phase 6: Background transition (0.58 → 0.75) ──
    _bgColorProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.58, 0.75, curve: Curves.easeInOut),
      ),
    );

    // ── Phase 7: Text appears (0.78 → 0.92) ──
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.78, 0.88, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.78, 0.92, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait a bit after the first frame is drawn to ensure native splash screen is gone
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      _mainController.forward();

      // Start bounce animation when mascot appears
      _mainController.addListener(() {
        if (_mainController.value >= 0.55 && !_bounceController.isAnimating) {
          _bounceController.repeat(reverse: true);
        }
      });

      // Navigate after animation completes + a short pause
      _mainController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/onboarding');
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _bounceController]),
      builder: (context, child) {
        final bgColor = Color.lerp(
          _purpleBg,
          _softPinkBg,
          _bgColorProgress.value,
        )!;

        final showFace = _mainController.value < 0.45;
        final showMascot = _mainController.value >= 0.42;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // ── Decorative gradient overlay ──
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Main content ──
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // === Kawaii Face (Phases 1–4) ===
                    if (showFace)
                      Opacity(
                        opacity:
                            _faceOpacity.value *
                            _faceShrink.value.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale:
                              _faceScale.value *
                              _faceShrink.value.clamp(0.15, 1.0),
                          child: SizedBox(
                            width: 160,
                            height: 80,
                            child: CustomPaint(
                              painter: KawaiiFacePainter(
                                blinkProgress: _isWinkPhase
                                    ? _winkProgress.value
                                    : _blinkProgress.value,
                                isWinking: _isWinkPhase,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // === Mascot Character (Phases 5–7) ===
                    if (showMascot) ...[
                      Opacity(
                        opacity: _mascotOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _bounceAnim.value),
                          child: Transform.scale(
                            scale: _mascotScale.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // White circle behind mascot
                                Opacity(
                                  opacity: _circleOpacity.value,
                                  child: Transform.scale(
                                    scale: _circleScale.value,
                                    child: Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _circleWhite.withValues(
                                          alpha: 0.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 40,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Mascot character
                                Image.asset(
                                  'assets/maskot/Maskot say hi (2).png',
                                  width: 180,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // "MindMate" text (Phase 7)
                      const SizedBox(height: 24),
                      Opacity(
                        opacity: _textOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: Column(
                            children: [
                              Text(
                                'MindMate',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Color.lerp(
                                    Colors.white,
                                    const Color(0xFF5E35B1),
                                    _bgColorProgress.value,
                                  ),
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: const Color(
                                        0xFF5E35B1,
                                      ).withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Opacity(
                                opacity: _textOpacity.value,
                                child: Text(
                                  'Learn with Fun',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color.lerp(
                                      Colors.white70,
                                      const Color(0xFF7E57C2),
                                      _bgColorProgress.value,
                                    ),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns true during the wink phase of the animation.
  bool get _isWinkPhase {
    final v = _mainController.value;
    return v >= 0.12 && v <= 0.22;
  }
}
