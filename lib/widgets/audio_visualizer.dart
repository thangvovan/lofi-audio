import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated audio visualizer bars that animate when playing.
/// Uses a single AnimationController + CustomPainter for efficient rendering
/// instead of N individual controllers (one per bar).
class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int barCount;
  final double width;
  final double height;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.color = AppColors.primary,
    this.barCount = 28,
    this.width = 280,
    this.height = 60,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Pre-generated per-bar random seeds so each bar has unique phase/frequency
  late final List<double> _phases;
  late final List<double> _frequencies;
  late final List<double> _minHeights;

  final _random = Random();

  @override
  void initState() {
    super.initState();

    // One controller driving the whole painter — replaces N controllers
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Seed per-bar random parameters once
    _phases = List.generate(
      widget.barCount,
      (_) => _random.nextDouble() * pi * 2,
    );
    _frequencies = List.generate(
      widget.barCount,
      (_) => 1.0 + _random.nextDouble() * 2.0, // 1x-3x speed multiplier
    );
    _minHeights = List.generate(
      widget.barCount,
      (_) => 0.08 + _random.nextDouble() * 0.10, // 8%–18% resting height
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        // Animate gently to resting position
        _controller.animateTo(0, duration: const Duration(milliseconds: 600));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _VisualizerPainter(
                animValue: _controller.value,
                isPlaying: widget.isPlaying,
                color: widget.color,
                barCount: widget.barCount,
                phases: _phases,
                frequencies: _frequencies,
                minHeights: _minHeights,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  final double animValue;
  final bool isPlaying;
  final Color color;
  final int barCount;
  final List<double> phases;
  final List<double> frequencies;
  final List<double> minHeights;

  _VisualizerPainter({
    required this.animValue,
    required this.isPlaying,
    required this.color,
    required this.barCount,
    required this.phases,
    required this.frequencies,
    required this.minHeights,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (barCount * 2);
    final spacing = barWidth * 0.6;
    final totalWidth = barWidth * barCount + spacing * (barCount - 1);
    final startX = (size.width - totalWidth) / 2;

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = isPlaying
        ? (Paint()
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6))
        : null;

    for (int i = 0; i < barCount; i++) {
      // Calculate bar height: sine wave with per-bar phase & frequency
      double heightFraction;
      if (isPlaying) {
        final t = animValue * 2 * pi * frequencies[i] + phases[i];
        heightFraction = (minHeights[i] + (sin(t) * 0.5 + 0.5) *
            (0.5 + _peakBoost(i, barCount) * 0.4))
            .clamp(0.05, 1.0);
      } else {
        // Gently settle bars to min height when paused
        final t = animValue * 2 * pi * 0.5 + phases[i];
        heightFraction = (minHeights[i] + sin(t) * 0.04).clamp(0.05, 0.25);
      }

      final barHeight = size.height * heightFraction;
      final x = startX + i * (barWidth + spacing);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        Radius.circular(barWidth / 2),
      );

      // Draw subtle glow behind active bars
      if (glowPaint != null && heightFraction > 0.3) {
        glowPaint.color = color.withValues(alpha: 0.15);
        canvas.drawRRect(rect, glowPaint);
      }

      // Draw the bar with gradient-like opacity shift (bottom bright, top soft)
      final opacity = isPlaying ? (0.55 + heightFraction * 0.45) : 0.35;
      fillPaint.color = color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawRRect(rect, fillPaint);
    }
  }

  /// Boost heights toward the center to create a natural dome shape.
  double _peakBoost(int i, int count) {
    final center = (count - 1) / 2;
    final dist = (i - center).abs() / center;
    return 1.0 - dist * 0.5; // 100% at center, 50% at edges
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter old) {
    // Only repaint when animation value or state actually changed
    return old.animValue != animValue ||
        old.isPlaying != isPlaying ||
        old.color != color;
  }
}

/// Small playing indicator (3 bars) for channel cards
class PlayingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const PlayingIndicator({
    super.key,
    this.color = AppColors.primary,
    this.size = 16,
  });

  @override
  State<PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const _barPhases = [0.0, 2.09, 4.19]; // 0, 2π/3, 4π/3

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (i) {
              final t = _controller.value * 2 * pi + _barPhases[i];
              final h = (sin(t) * 0.5 + 0.5) * 0.7 + 0.3;
              return Container(
                width: widget.size * 0.2,
                height: widget.size * h,
                margin: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.size * 0.1),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
