import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A retro-themed animated pixel-art cassette tape player.
class PixelCassettePlayer extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final String title;
  final VoidCallback? onTap;

  const PixelCassettePlayer({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.title,
    this.onTap,
  });

  @override
  State<PixelCassettePlayer> createState() => _PixelCassettePlayerState();
}

class _PixelCassettePlayerState extends State<PixelCassettePlayer>
    with TickerProviderStateMixin {
  late AnimationController _reelController;
  late AnimationController _ledController;
  late Animation<double> _ledGlowAnimation;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();

    // Controller for spinning the tape reels
    _reelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Controller for breathing LED glow when loading
    _ledController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _ledGlowAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ledController, curve: Curves.easeInOut));

    if (widget.isPlaying) {
      _reelController.repeat();
    }
    if (widget.isLoading) {
      _ledController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PixelCassettePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle play state transitions
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _reelController.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _reelController.stop();
    }

    // Handle loading state transitions
    if (widget.isLoading && !oldWidget.isLoading) {
      _ledController.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _ledController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.94;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
        });
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0;
        });
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 0
                ? constraints.maxWidth
                : 300.0;
            final height = width * 0.62; // Cassette aspect ratio

            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  // Pulse/glow backing for the active state
                  BoxShadow(
                    color: widget.isPlaying
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Painted Cassette Deck Chassis
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CassetteChassisPainter(
                        isPlaying: widget.isPlaying,
                        isLoading: widget.isLoading,
                      ),
                    ),
                  ),

                  // Spinning Reels
                  Positioned(
                    left: width * 0.24,
                    top: height * 0.44,
                    child: AnimatedBuilder(
                      animation: _reelController,
                      builder: (context, child) {
                        return ReelWidget(
                          rotation: _reelController.value * 2 * pi,
                          size: width * 0.16,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: width * 0.24,
                    top: height * 0.44,
                    child: AnimatedBuilder(
                      animation: _reelController,
                      builder: (context, child) {
                        // Right reel spins at same rate, offset a bit for asymmetry
                        return ReelWidget(
                          rotation: -_reelController.value * 2 * pi + 0.5,
                          size: width * 0.16,
                        );
                      },
                    ),
                  ),

                  // Dynamic Tape Label Text
                  Positioned(
                    left: width * 0.16,
                    right: width * 0.16,
                    top: height * 0.14,
                    child: Container(
                      height: height * 0.22,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        widget.title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors
                              .surface, // Dark contrast on the light label
                          fontFamily: 'Outfit',
                          fontSize: (width * 0.04).clamp(10, 14),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // LED Indicators
                  Positioned(
                    left: width * 0.08,
                    bottom: height * 0.08,
                    child: AnimatedBuilder(
                      animation: _ledGlowAnimation,
                      builder: (context, child) {
                        Color ledColor;
                        double opacity;

                        if (widget.isLoading) {
                          ledColor = AppColors.secondary;
                          opacity = _ledGlowAnimation.value;
                        } else if (widget.isPlaying) {
                          ledColor = AppColors.primary;
                          opacity = 1.0;
                        } else {
                          ledColor = AppColors.inactiveText.withValues(
                            alpha: 0.5,
                          );
                          opacity = 0.5;
                        }

                        return Container(
                          width: width * 0.035,
                          height: width * 0.035,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ledColor.withValues(alpha: opacity),
                            boxShadow: [
                              if (widget.isPlaying || widget.isLoading)
                                BoxShadow(
                                  color: ledColor.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reelController.dispose();
    _ledController.dispose();
    super.dispose();
  }
}

// Draws the shell container and inner window of the cassette tape.
class CassetteChassisPainter extends CustomPainter {
  final bool isPlaying;
  final bool isLoading;

  CassetteChassisPainter({required this.isPlaying, required this.isLoading});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw outer cassette shell
    final shellRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(16),
    );
    final shellPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawRRect(shellRect, shellPaint);

    // Draw outer neon grid line border
    final borderPaint = Paint()
      ..color = isPlaying
          ? AppColors.primary.withValues(alpha: 0.5)
          : AppColors.secondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(shellRect, borderPaint);

    // Draw top design stripes on cassette shell
    final stripePaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(w * 0.05, h * 0.1),
      Offset(w * 0.95, h * 0.1),
      stripePaint,
    );

    // Draw central sticker label
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.12, w * 0.76, h * 0.26),
      const Radius.circular(6),
    );
    final labelPaint = Paint()
      ..color = AppColors.onSurface
          .withValues(alpha: 0.85) // Translucent light label
      ..style = PaintingStyle.fill;
    canvas.drawRRect(labelRect, labelPaint);

    // Draw secondary colored stripe inside the label
    final labelStripePaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        w * 0.12,
        h * 0.12 + (h * 0.26 * 0.75),
        w * 0.76,
        h * 0.26 * 0.2,
      ),
      labelStripePaint,
    );

    // Draw center clear tape window cutout
    final windowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.42, w * 0.6, h * 0.38),
      const Radius.circular(10),
    );
    final windowPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
    canvas.drawRRect(windowRect, windowPaint);

    final windowBorderPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(windowRect, windowBorderPaint);

    // Bottom trapezoidal cuts
    final path = Path()
      ..moveTo(w * 0.32, h)
      ..lineTo(w * 0.36, h * 0.9)
      ..lineTo(w * 0.64, h * 0.9)
      ..lineTo(w * 0.68, h)
      ..close();

    // Draw decorative accent notchs at the bottom
    final notchPaint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, notchPaint);
  }

  @override
  bool shouldRepaint(covariant CassetteChassisPainter oldDelegate) {
    return oldDelegate.isPlaying != isPlaying ||
        oldDelegate.isLoading != isLoading;
  }
}

// Individual animated spinning reel inside the cassette window.
class ReelWidget extends StatelessWidget {
  final double rotation;
  final double size;

  const ReelWidget({super.key, required this.rotation, required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(size: Size(size, size), painter: ReelPainter()),
    );
  }
}

// Paints a circular gear spool representing the cassette tape reels.
class ReelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer reel circle
    final outerReelPaint = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerReelPaint);

    // Draw inner gear track
    final gearTrackPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.45, gearTrackPaint);

    // Draw teeth representing the analog spindle lock
    final spokeDistance = radius * 0.38;
    final spokeRadius = radius * 0.08;

    final spokePaint = Paint()
      ..color = AppColors.onSurface.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final spokeCenter = Offset(
        center.dx + spokeDistance * cos(angle),
        center.dy + spokeDistance * sin(angle),
      );
      canvas.drawCircle(spokeCenter, spokeRadius, spokePaint);
    }

    // Center hub cutout
    final hubPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.22, hubPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
