import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/pixel_cassette_player.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        final channel = provider.currentChannel;
        if (channel == null) {
          Navigator.of(context).pop();
          return const SizedBox.shrink();
        }

        return Scaffold(
          body: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 300) { // Swift swipe down pops screen
                Navigator.of(context).pop();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
              // Blurred background thumbnail
              CachedNetworkImage(
                imageUrl: channel.maxThumbnailUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    Container(color: AppColors.background),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0.6),
                        AppColors.background.withValues(alpha: 0.85),
                        AppColors.background.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Top drag handle indicator
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // App bar
                    _buildAppBar(context),
                    const Spacer(flex: 1),

                    // Album art (Animated Pixel Cassette Player)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Hero(
                        tag: 'player_thumbnail',
                        child: Material(
                          color: Colors.transparent,
                          child: PixelCassettePlayer(
                            isPlaying: provider.isPlaying,
                            isLoading: provider.isLoadingStream,
                            title: channel.title,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    _buildTitle(context, channel),
                    const SizedBox(height: 24),

                    // Visualizer or Error Panel
                    if (provider.error != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  provider.error!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded,
                                    color: Colors.white70, size: 20),
                                onPressed: () => provider.playChannel(channel),
                                tooltip: 'Thử lại',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      AudioVisualizer(
                        isPlaying: provider.isPlaying,
                        color: AppColors.primary,
                        barCount: 32,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Controls
                    _buildControls(context, provider),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white70, size: 32),
            tooltip: 'Đóng',
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'ĐANG PHÁT TỪ',
                  style: TextStyle(
                    color: AppColors.inactiveText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lofi Radio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance with back button
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, dynamic channel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            channel.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, AudioProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        _buildControlButton(
          icon: Icons.skip_previous_rounded,
          onTap: provider.previous,
          size: 36,
          color: Colors.white70,
        ),
        const SizedBox(width: 24),

        // Play/Pause (large)
        _buildPlayPauseButton(provider),
        const SizedBox(width: 24),

        // Next
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          onTap: provider.next,
          size: 36,
          color: Colors.white70,
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(AudioProvider provider) {
    return Semantics(
      label: provider.isPlaying ? 'Tạm dừng' : 'Phát nhạc',
      button: true,
      child: _BounceScaleWidget(
        onTap: provider.isLoadingStream ? () {} : provider.togglePlayPause,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFFBF3250)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: provider.isLoadingStream
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  provider.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
    required Color color,
  }) {
    final String label = icon == Icons.skip_previous_rounded
        ? 'Kênh trước'
        : 'Kênh tiếp theo';

    return Semantics(
      label: label,
      button: true,
      child: _BounceScaleWidget(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}

/// A tactile button widget that scales down slightly on press.
class _BounceScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BounceScaleWidget({
    required this.child,
    required this.onTap,
  });

  @override
  State<_BounceScaleWidget> createState() => _BounceScaleWidgetState();
}

class _BounceScaleWidgetState extends State<_BounceScaleWidget>
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
