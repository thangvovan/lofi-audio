import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../screens/player_screen.dart';
import '../theme/app_colors.dart';
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
              color: AppColors.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
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
                        color: AppColors.shimmerHighlight,
                        child: const Icon(Icons.music_note,
                            color: AppColors.inactiveText, size: 20),
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
                          color: AppColors.onSurface,
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
                                color: AppColors.primary,
                              ),
                            )
                          else if (provider.isPlaying)
                            const PlayingIndicator(
                                size: 12, color: AppColors.primary)
                          else
                            const Icon(Icons.pause,
                                size: 12, color: AppColors.inactiveText),
                          const SizedBox(width: 6),
                          Text(
                            provider.isLoadingStream
                                ? 'Đang tải...'
                                : provider.isPlaying
                                    ? 'Đang phát'
                                    : 'Tạm dừng',
                            style: const TextStyle(
                              color: AppColors.inactiveText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Controls:  ▶  🔉 80% 🔊
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PlayPauseButton(
                      isPlaying: provider.isPlaying,
                      isLoading: provider.isLoadingStream,
                      onTap: provider.togglePlayPause,
                    ),
                    const SizedBox(width: 8),
                    _ControlButton(
                      icon: Icons.volume_down_rounded,
                      onTap: provider.volumeDown,
                      label: 'Giảm âm lượng',
                      size: 20,
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${(provider.volume * 100).round()}%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onSurface.withValues(alpha: 0.45),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _ControlButton(
                      icon: Icons.volume_up_rounded,
                      onTap: provider.volumeUp,
                      label: 'Tăng âm lượng',
                      size: 20,
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
  final String label;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.label,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: BounceScaleWidget(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: AppColors.onSurface.withValues(alpha: 0.7),
            size: size,
          ),
        ),
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
    return Semantics(
      label: isPlaying ? 'Tạm dừng' : 'Phát nhạc',
      button: true,
      child: BounceScaleWidget(
        onTap: isLoading ? () {} : onTap,
        child: Padding(
          padding: const EdgeInsets.all(6), // Enlarge touch zone from 36 to 48 dp
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onSurface,
                    ),
                  )
                : Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.onSurface,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}

/// A tactile button widget that scales down slightly on press.
class BounceScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BounceScaleWidget({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<BounceScaleWidget> createState() => _BounceScaleWidgetState();
}

class _BounceScaleWidgetState extends State<BounceScaleWidget>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
