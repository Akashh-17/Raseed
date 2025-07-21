import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_gate.dart'; // <-- Use AuthGate instead of AuthScreen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _page = 0.0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      svgAsset: 'assets/receipt_logo.svg',
      title: 'Smart Receipt Analysis',
      subtitle: 'Scan, organize & track your spends — effortlessly.',
      showLogo: true,
    ),
    _OnboardingData(
      svgAsset: 'assets/scan_insight.svg',
      title: 'Scan & Categorize',
      subtitle: 'Understand where your money goes with every receipt.',
    ),
    _OnboardingData(
      svgAsset: 'assets/calendar_shield.svg',
      title: 'Never Miss a Due Date',
      subtitle: 'Stay ahead with reminders for payments & warranties.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _page = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: Colors.white.withOpacity(0.82)),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final progress = (_page - index).clamp(-1.0, 1.0);
                      return _AnimatedOnboardingPage(
                        data: _pages[index],
                        progress: progress,
                        pageIndex: index,
                        totalPages: _pages.length,
                      );
                    },
                  ),
                ),
                _PageIndicator(current: _page.round(), count: _pages.length),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        _page.round() == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2341),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        if (_page.round() == _pages.length - 1) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('onboarding_completed', true);
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const AuthGate(),
                              ),
                            );
                          }
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.ease,
                          );
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _getTaglineWithIcon(_page.round()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Remaining helper classes (unchanged) — kept below for completeness

class _OnboardingData {
  final String svgAsset;
  final String title;
  final String subtitle;
  final bool showLogo;

  const _OnboardingData({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    this.showLogo = false,
  });
}

class _AnimatedOnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final double progress;
  final int pageIndex;
  final int totalPages;

  const _AnimatedOnboardingPage({
    required this.data,
    required this.progress,
    required this.pageIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final svgOffset = 40.0 * progress;
    final svgOpacity = (1.0 - progress.abs()).clamp(0.0, 1.0);
    final svgScale = 0.92 + 0.08 * (1.0 - progress.abs());
    final titleOpacity = (1.0 - progress.abs() * 1.2).clamp(0.0, 1.0);
    final subtitleOpacity = (1.0 - progress.abs() * 1.6).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: data.showLogo ? 24 : 48),
                SizedBox(
                  height: 180,
                  child: Opacity(
                    opacity: svgOpacity,
                    child: Transform.translate(
                      offset: Offset(0, svgOffset),
                      child: Transform.scale(
                        scale: svgScale,
                        child: SvgPicture.asset(data.svgAsset, height: 180),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Opacity(
                  opacity: data.showLogo ? 1 : 0,
                  child: Text(
                    data.showLogo ? 'RASEED' : '',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1A2341),
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Opacity(
                  opacity: titleOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (data.title.contains('Analysis'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.teal,
                            size: 22,
                          ),
                        ),
                      if (data.title.contains('Scan'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.qr_code_scanner,
                            color: Colors.teal,
                            size: 22,
                          ),
                        ),
                      if (data.title.contains('Due Date'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.shield,
                              color: Colors.teal,
                              size: 18,
                            ),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2341),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Opacity(
                  opacity: subtitleOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      data.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : const Color(0xFF4B587C),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int current;
  final int count;

  const _PageIndicator({required this.current, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: current == index ? 12 : 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: current == index
                  ? const Color(0xFF1A2341)
                  : const Color(0xFFD9D9D9),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _getTaglineWithIcon(int page) {
  switch (page) {
    case 0:
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/receipt_logo.svg', height: 18, width: 18),
          const SizedBox(width: 7),
          const Flexible(
            child: Text(
              'Track every rupee better',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7A869A),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      );
    case 1:
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/scan_insight.svg', height: 18, width: 18),
          const SizedBox(width: 7),
          const Flexible(
            child: Text(
              'From paper to power — with Raseed',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7A869A),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      );
    case 2:
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/calendar_shield.svg', height: 18, width: 18),
          const SizedBox(width: 7),
          const Flexible(
            child: Text(
              'Smart reminders. Peace of mind.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7A869A),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      );
    default:
      return const SizedBox.shrink();
  }
}
