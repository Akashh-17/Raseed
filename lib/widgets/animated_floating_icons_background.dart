import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedFloatingIconsBackground extends StatefulWidget {
  const AnimatedFloatingIconsBackground({super.key});

  @override
  State<AnimatedFloatingIconsBackground> createState() =>
      _AnimatedFloatingIconsBackgroundState();
}

class _AnimatedFloatingIconsBackgroundState
    extends State<AnimatedFloatingIconsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingIconData> _icons = [
    _FloatingIconData('assets/icons/spotify.png', 32),
    _FloatingIconData('assets/icons/youtube.png', 36),
    _FloatingIconData('assets/icons/netflix.png', 34),
    _FloatingIconData('assets/icons/prime.png', 30),
    _FloatingIconData('assets/icons/gpay.png', 28),
    _FloatingIconData('assets/icons/chatgpt.png', 30),
    _FloatingIconData('assets/icons/flipkart.png', 28),
    _FloatingIconData('assets/icons/swiggy.png', 26),
    // Add more as needed
  ];
  final Random _random = Random();
  late List<_IconAnimation> _iconAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _iconAnimations =
        _icons.map((icon) {
          final startX = _random.nextDouble();
          final startY = _random.nextDouble();
          final driftX = (_random.nextDouble() - 0.5) * 0.2;
          final driftY = (_random.nextDouble() - 0.5) * 0.2;
          final scale = 0.8 + _random.nextDouble() * 0.6;
          final opacity = 0.18 + _random.nextDouble() * 0.18;
          return _IconAnimation(
            icon: icon,
            startX: startX,
            startY: startY,
            driftX: driftX,
            driftY: driftY,
            scale: scale,
            opacity: opacity,
          );
        }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children:
                _iconAnimations.asMap().entries.map((entry) {
                  final i = entry.key;
                  final anim = entry.value;
                  final t = (_controller.value + anim.startX) % 1.0;
                  final dx = anim.startX + anim.driftX * t;
                  final dy = anim.startY + anim.driftY * t;
                  return Positioned(
                    left: dx * MediaQuery.of(context).size.width,
                    top: dy * MediaQuery.of(context).size.height,
                    child: Opacity(
                      opacity: anim.opacity,
                      child: _SafeIconOrCircle(
                        asset: anim.icon.asset,
                        size: anim.icon.size * anim.scale,
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}

class _SafeIconOrCircle extends StatelessWidget {
  final String asset;
  final double size;
  const _SafeIconOrCircle({required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: Colors.white,
      colorBlendMode: BlendMode.modulate,
      errorBuilder:
          (context, error, stackTrace) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
    );
  }
}

class _FloatingIconData {
  final String asset;
  final double size;
  const _FloatingIconData(this.asset, this.size);
}

class _IconAnimation {
  final _FloatingIconData icon;
  final double startX, startY, driftX, driftY, scale, opacity;
  _IconAnimation({
    required this.icon,
    required this.startX,
    required this.startY,
    required this.driftX,
    required this.driftY,
    required this.scale,
    required this.opacity,
  });
}
