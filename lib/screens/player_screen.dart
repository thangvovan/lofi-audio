import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/audio_visualizer.dart';

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
          body: Stack(
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
                    // App bar
                    _buildAppBar(context),
                    const Spacer(flex: 1),

                    // Album art
                    _buildAlbumArt(context, channel, provider),
                    const SizedBox(height: 32),

                    // Title
                    _buildTitle(context, channel),
                    const SizedBox(height: 24),

                    // Visualizer
                    AudioVisualizer(
                      isPlaying: provider.isPlaying,
                      color: AppColors.primary,
                      barCount: 32,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                    ),
                    const SizedBox(height: 32),

                    // Controls
                    _buildControls(context, provider),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ],
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

  Widget _buildAlbumArt(
      BuildContext context, dynamic channel, AudioProvider provider) {
    final size = MediaQuery.of(context).size.width * 0.7;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Hero(
              tag: 'player_thumbnail',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: channel.maxThumbnailUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.music_note,
                        color: AppColors.inactiveText, size: 80),
                  ),
                ),
              ),
            ),

            // Live badge
            if (channel.isLive)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_manual_record,
                          color: Colors.white, size: 10),
                      SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Loading overlay
            if (provider.isLoadingStream)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
          const SizedBox(height: 6),
          const Text(
            'Lofi Radio',
            style: TextStyle(
              color: AppColors.inactiveText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
    return GestureDetector(
      onTap: provider.isLoadingStream ? null : provider.togglePlayPause,
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
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
    required Color color,
  }) {
    return GestureDetector(
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
    );
  }
}
