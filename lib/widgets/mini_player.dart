import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../screens/player_screen.dart';
import 'audio_visualizer.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        if (!provider.hasCurrentChannel) {
          return const SizedBox.shrink();
        }

        final channel = provider.currentChannel!;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const PlayerScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(
              12,
              0,
              12,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF533483).withValues(alpha: 0.3),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
                BoxShadow(
                  color: const Color(0xFFE94560).withValues(alpha: 0.05),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail
                Hero(
                  tag: 'player_thumbnail',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: channel.thumbnailUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 44,
                        height: 44,
                        color: const Color(0xFF2A2A4E),
                        child: const Icon(Icons.music_note,
                            color: Color(0xFF8D8DAA), size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Status
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (provider.isLoadingStream)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Color(0xFFE94560),
                              ),
                            )
                          else if (provider.isPlaying)
                            const PlayingIndicator(
                                size: 12, color: Color(0xFFE94560))
                          else
                            const Icon(Icons.pause,
                                size: 12, color: Color(0xFF8D8DAA)),
                          const SizedBox(width: 6),
                          Text(
                            provider.isLoadingStream
                                ? 'Đang tải...'
                                : provider.isPlaying
                                    ? 'Đang phát'
                                    : 'Tạm dừng',
                            style: const TextStyle(
                              color: Color(0xFF8D8DAA),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ControlButton(
                      icon: Icons.skip_previous_rounded,
                      onTap: provider.previous,
                      size: 28,
                    ),
                    const SizedBox(width: 4),
                    _PlayPauseButton(
                      isPlaying: provider.isPlaying,
                      isLoading: provider.isLoadingStream,
                      onTap: provider.togglePlayPause,
                    ),
                    const SizedBox(width: 4),
                    _ControlButton(
                      icon: Icons.skip_next_rounded,
                      onTap: provider.next,
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white70, size: size),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFE94560), Color(0xFF533483)],
          ),
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
      ),
    );
  }
}
