import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// An audio-reactive, high-performance particle background widget.
/// Simulates floating celestial dust and cosmic sparks that react to the play state.
/// Respects OS-level accessibility "reduced motion" flags.
class SpaceNebulaBg extends StatefulWidget {
  final bool isPlaying;

  const SpaceNebulaBg({
    super.key,
    required this.isPlaying,
  });

  @override
  State<SpaceNebulaBg> createState() => _SpaceNebulaBgState();
}

class _SpaceNebulaBgState extends State<SpaceNebulaBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initParticles(Size size) {
    _screenSize = size;
    _particles.clear();
    const particleCount = 45;

    for (int i = 0; i < particleCount; i++) {
      // Curated color mix from Synthwave Sanctuary palette
      final colorRand = _random.nextDouble();
      Color color;
      if (colorRand < 0.3) {
        color = AppColors.primary; // Radiant Neon Red
      } else if (colorRand < 0.65) {
        color = AppColors.secondary; // Soft Deep Violet
      } else {
        color = AppColors.tertiary.withValues(alpha: 0.8); // Deep Teal/Blue
      }

      _particles.add(
        _Particle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          vx: (_random.nextDouble() - 0.5) * 0.3,
          vy: -(_random.nextDouble() * 0.4 + 0.1), // Float upwards
          size: _random.nextDouble() * 3.0 + 1.5,
          opacity: _random.nextDouble() * 0.5 + 0.15,
          color: color,
          pulseSpeed: _random.nextDouble() * 0.05 + 0.02,
          pulsePhase: _random.nextDouble() * pi * 2,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Respect user's system accessibility "reduced motion" settings
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_screenSize != size) {
          _initParticles(size);
        }

        if (disableAnimations) {
          // Render static particle field without animation loop
          return RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: _ParticleFieldPainter(
                particles: _particles,
                isPlaying: false,
                animationValue: 0.0,
              ),
            ),
          );
        }

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              _updateParticles(size);
              return CustomPaint(
                size: size,
                painter: _ParticleFieldPainter(
                  particles: _particles,
                  isPlaying: widget.isPlaying,
                  animationValue: _controller.value,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _updateParticles(Size size) {
    // Tweak speed based on active playback state
    final double speedFactor = widget.isPlaying ? 1.5 : 0.25;

    for (final p in _particles) {
      // Dynamic sine-wave drift to create fluid cosmic movement
      p.x += (p.vx + sin(p.pulsePhase) * 0.05) * speedFactor;
      p.y += p.vy * speedFactor;
      p.pulsePhase += p.pulseSpeed * (widget.isPlaying ? 2.0 : 0.5);

      // Boundary wraps
      if (p.x < 0) p.x = size.width;
      if (p.x > size.width) p.x = 0;
      if (p.y < 0) {
        p.y = size.height;
        p.x = _random.nextDouble() * size.width;
      }
    }
  }
}

class _Particle {
  double x;
  double y;
  final double vx;
  final double vy;
  final double size;
  final double opacity;
  final Color color;
  final double pulseSpeed;
  double pulsePhase;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.color,
    required this.pulseSpeed,
    required this.pulsePhase,
  });
}

class _ParticleFieldPainter extends CustomPainter {
  final List<_Particle> particles;
  final bool isPlaying;
  final double animationValue;

  // Reusable Paint instances — created once, not per-frame
  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _glowPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

  _ParticleFieldPainter({
    required this.particles,
    required this.isPlaying,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Dynamic breathing glow phase
      final double breath = isPlaying ? sin(p.pulsePhase) * 0.35 + 0.65 : 0.7;
      final double finalOpacity = (p.opacity * breath).clamp(0.05, 0.9);

      _fillPaint.color = p.color.withValues(alpha: finalOpacity);

      // Draw a soft glowing halo for active states (only large particles)
      if (isPlaying && p.size > 2.5) {
        _glowPaint.color = p.color.withValues(alpha: finalOpacity * 0.2);
        canvas.drawCircle(Offset(p.x, p.y), p.size * 2.2, _glowPaint);
      }

      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size * (isPlaying ? breath * 1.1 : 1.0),
        _fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleFieldPainter oldDelegate) {
    // When playing: always repaint (particles are moving)
    // When paused: only repaint if isPlaying state changed (not every frame)
    if (oldDelegate.isPlaying != isPlaying) return true;
    if (!isPlaying) return false; // Paused — no movement needed
    return true;
  }
}
