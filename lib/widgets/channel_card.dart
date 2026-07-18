import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/lofi_channel.dart';
import 'audio_visualizer.dart';

class ChannelCard extends StatelessWidget {
  final LofiChannel channel;
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isCurrentlyPlaying
              ? Border.all(
                  color: const Color(0xFFE94560).withValues(alpha: 0.6),
                  width: 1.5,
                )
              : null,
          boxShadow: isCurrentlyPlaying
              ? [
                  BoxShadow(
                    color: const Color(0xFFE94560).withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Thumbnail
              AspectRatio(
                aspectRatio: 16 / 10,
                child: CachedNetworkImage(
                  imageUrl: channel.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: const Color(0xFF1A1A2E),
                    highlightColor: const Color(0xFF2A2A4E),
                    child: Container(color: const Color(0xFF1A1A2E)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF1A1A2E),
                    child: const Icon(
                      Icons.music_note,
                      color: Color(0xFF8D8DAA),
                      size: 40,
                    ),
                  ),
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        const Color(0xFF0D0D1A).withValues(alpha: 0.7),
                        const Color(0xFF0D0D1A).withValues(alpha: 0.95),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // LIVE badge
              if (channel.isLive)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE94560),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE94560).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record,
                            color: Colors.white, size: 8),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Playing indicator
              if (isCurrentlyPlaying)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D1A).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isPlaying
                        ? const PlayingIndicator(size: 14)
                        : const Icon(Icons.pause,
                            color: Color(0xFFE94560), size: 14),
                  ),
                ),

              // Title overlay at bottom
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  channel.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
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
}
