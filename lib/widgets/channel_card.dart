import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/radio_channel.dart';
import '../theme/app_colors.dart';

// A bold, retro-themed Channel Card shaped like a mini physical cassette tape.
class ChannelCard extends StatefulWidget {
  final RadioChannel channel;
  final bool isCurrentlyPlaying;
  final bool isPlaying;
  final VoidCallback onTap;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.isCurrentlyPlaying,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ChannelCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying && !oldWidget.isPlaying) {
      _rotationController.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _rotationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isCurrentlyPlaying
                ? AppColors.primary
                : AppColors.secondary.withValues(alpha: 0.3),
            width: widget.isCurrentlyPlaying ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isCurrentlyPlaying
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: widget.isCurrentlyPlaying ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Painted Cassette Deck Outlines
              Positioned.fill(
                child: CustomPaint(
                  painter: _CardCassetteBodyPainter(
                    isCurrentlyPlaying: widget.isCurrentlyPlaying,
                  ),
                ),
              ),

              // Sticker Label
              Positioned(
                left: 10,
                right: 10,
                top: 10,
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.onSurface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.channel.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              // Clear window cutout revealing the thumbnail inside
              Positioned(
                left: 20,
                right: 20,
                bottom: 12,
                top: 50,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: widget.channel.thumbnailUrl,
                          fit: BoxFit.cover,
                          // Limit in-memory decode size
                          memCacheWidth: 320,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: AppColors.shimmerBase,
                            highlightColor: AppColors.shimmerHighlight,
                            child: Container(color: AppColors.surface),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.background,
                            child: const Icon(
                              Icons.music_note,
                              color: AppColors.inactiveText,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Inner glossy glare effect
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.background,
                            width: 2.0,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.onSurface.withValues(alpha: 0.05),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Left spinning spindle reel
                    Positioned(
                      left: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return _MiniReelWidget(
                              rotation: _rotationController.value * 2 * pi,
                              size: 20,
                            );
                          },
                        ),
                      ),
                    ),

                    // Right spinning spindle reel
                    Positioned(
                      right: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return _MiniReelWidget(
                              rotation:
                                  -_rotationController.value * 2 * pi + 0.5,
                              size: 20,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Glowing indicator LED
              if (widget.channel.isLive)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isPlaying
                          ? AppColors.primary
                          : AppColors.secondary,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (widget.isPlaying
                                      ? AppColors.primary
                                      : AppColors.secondary)
                                  .withValues(alpha: 0.8),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
}

// Paints subtle structural lines on the cassette plastic tape shell.
class _CardCassetteBodyPainter extends CustomPainter {
  final bool isCurrentlyPlaying;

  _CardCassetteBodyPainter({required this.isCurrentlyPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Horizontal structural ridges
    final linePaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, h * 0.35), Offset(w, h * 0.35), linePaint);
    canvas.drawLine(Offset(0, h * 0.78), Offset(w, h * 0.78), linePaint);

    // Bottom center plastic trapezoid insert
    final path = Path()
      ..moveTo(w * 0.28, h)
      ..lineTo(w * 0.34, h * 0.94)
      ..lineTo(w * 0.66, h * 0.94)
      ..lineTo(w * 0.72, h)
      ..close();

    final notchPaint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, notchPaint);
  }

  @override
  bool shouldRepaint(covariant _CardCassetteBodyPainter oldDelegate) {
    return oldDelegate.isCurrentlyPlaying != isCurrentlyPlaying;
  }
}

// A compact spindle widget placed inside the cassette window.
class _MiniReelWidget extends StatelessWidget {
  final double rotation;
  final double size;

  const _MiniReelWidget({required this.rotation, required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(size: Size(size, size), painter: _MiniReelPainter()),
    );
  }
}

// Paints a small 4-spoke circular gear for the mini cassette cards.
class _MiniReelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer gear spool
    final outerPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerPaint);

    // 4 spokes representing the spindle gear teeth
    final spokeDist = radius * 0.45;
    final spokeRadius = radius * 0.15;

    final spokePaint = Paint()
      ..color = AppColors.onSurface.withValues(alpha: 0.54)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final spokeCenter = Offset(
        center.dx + spokeDist * cos(angle),
        center.dy + spokeDist * sin(angle),
      );
      canvas.drawCircle(spokeCenter, spokeRadius, spokePaint);
    }

    // Hub core cutout
    final hubPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.2, hubPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
