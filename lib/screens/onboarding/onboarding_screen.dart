import 'package:flutter/material.dart';
import 'package:application_belajar/config/theme.dart';
import 'package:application_belajar/widgets/onboarding_illustrations.dart';

/// MindMate Onboarding Screen – 3-page carousel matching the design.
///
/// Page 1: Welcome – mascot with sparkles
/// Page 2: Coins – task cards with floating coins + mascot
/// Page 3: Puzzle – puzzle progress card + grid + mascot
///
/// Features:
/// - Animated progress bar at the top
/// - Smooth page transitions
/// - Decorative background elements
/// - "Next" / "Start" button at the bottom
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _bgDecoController;

  static const _totalPages = 3;

  // Onboarding data
  static const _pages = [
    _OnboardingData(
      title: 'Welcome To Mindmate!',
      subtitle: 'productivity apps that keep you\nfocused, consistent and fun!',
    ),
    _OnboardingData(
      title: 'Get Coins for Every Task',
      subtitle:
          'Turn your completed tasks into coins\nyou can spend on things you love.',
    ),
    _OnboardingData(
      title: 'Complete The Puzzle',
      subtitle: 'Collect 6 puzzle pieces every day to\nlight up your streak 🔥',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _bgDecoController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgDecoController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Decorative background dots/circles ──
          _buildBackgroundDecorations(),

          // ── Main content ──
          Column(
            children: [
              SizedBox(height: topPadding + 16),

              // ── Progress Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _buildProgressBar(),
              ),

              // ── Page Content ──
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    return _buildPage(index, screenHeight);
                  },
                ),
              ),

              // ── Bottom Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: _buildNextButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROGRESS BAR (animated, segmented)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Row(
      children: List.generate(_totalPages, (index) {
        final isActive = index <= _currentPage;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            height: 5,
            margin: EdgeInsets.only(right: index < _totalPages - 1 ? 6 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isActive ? AppColors.primary : const Color(0xFFE8D5FF),
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAGE CONTENT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPage(int index, double screenHeight) {
    final data = _pages[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Illustration area (takes about 50% of available space)
          Expanded(flex: 5, child: Center(child: _buildIllustration(index))),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),

          // Bottom spacing
          const Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildIllustration(int index) {
    switch (index) {
      case 0:
        return const WelcomeIllustration();
      case 1:
        return const TaskCoinsIllustration();
      case 2:
        return const PuzzleIllustration();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NEXT / START BUTTON
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNextButton() {
    final isLastPage = _currentPage == _totalPages - 1;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            isLastPage ? 'Start' : 'Next',
            key: ValueKey(isLastPage),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BACKGROUND DECORATIONS (subtle floating shapes)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBackgroundDecorations() {
    return AnimatedBuilder(
      animation: _bgDecoController,
      builder: (context, child) {
        final v = _bgDecoController.value;
        return Stack(
          children: [
            // Top-right soft circle
            Positioned(
              top: -30 + v * 15,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3E8FF).withValues(alpha: 0.5),
                ),
              ),
            ),
            // Bottom-left soft circle
            Positioned(
              bottom: -40 + v * 10,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3E8FF).withValues(alpha: 0.4),
                ),
              ),
            ),
            // Middle-right tiny dot
            Positioned(
              top: 200 + v * 20,
              right: 40,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8D5FF).withValues(alpha: 0.6),
                ),
              ),
            ),
            // Top-left tiny dot
            Positioned(
              top: 120 - v * 10,
              left: 30,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8D5FF).withValues(alpha: 0.5),
                ),
              ),
            ),
            // Center-left decorative dot
            Positioned(
              top: 350 + v * 15,
              left: 50,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3E8FF).withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────
class _OnboardingData {
  final String title;
  final String subtitle;

  const _OnboardingData({required this.title, required this.subtitle});
}
