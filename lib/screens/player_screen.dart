import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/mini_player.dart' show BounceScaleWidget;
import '../widgets/pixel_cassette_player.dart';
import '../widgets/space_nebula_bg.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        final channel = provider.currentChannel;

        if (channel == null) {
          return const SizedBox.shrink();
        }

        return Dismissible(
          key: const Key('player_dismiss'),
          direction: DismissDirection.down,
          onDismissed: (_) => Navigator.of(context).pop(),
          child: Scaffold(
            body: PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) {
                  // Reset status bar brightness when popping player screen
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

                  // Particle background overlay — isolated repaint layer
                  RepaintBoundary(
                    child: SpaceNebulaBg(isPlaying: provider.isPlaying),
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
                              color: AppColors.onSurface.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: OrientationBuilder(
                            builder: (context, orientation) {
                              return orientation == Orientation.landscape
                                  ? _buildLandscapeLayout(context, channel, provider)
                                  : _buildPortraitLayout(context, channel, provider);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(BuildContext context, dynamic channel, AudioProvider provider) {
    return Column(
      children: [
        _buildAppBar(context),
        const Spacer(flex: 1),

        // Album art (Animated Pixel Cassette Player) — isolated repaint layer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Hero(
            tag: 'player_thumbnail',
            child: Material(
              color: Colors.transparent,
              child: RepaintBoundary(
                child: PixelCassettePlayer(
                  isPlaying: provider.isPlaying,
                  isLoading: provider.isLoadingStream,
                  title: channel.title,
                  onTap: provider.togglePlayPause,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Title
        _buildTitle(context, channel),
        const SizedBox(height: 24),

        if (provider.error != null) ...[
          _buildErrorPanel(context, provider, channel),
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
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, dynamic channel, AudioProvider provider) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: Row(
            children: [
              // Left half: Cassette Player + Visualizer
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Hero(
                        tag: 'player_thumbnail',
                        child: Material(
                          color: Colors.transparent,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: PixelCassettePlayer(
                              isPlaying: provider.isPlaying,
                              isLoading: provider.isLoadingStream,
                              title: channel.title,
                              onTap: provider.togglePlayPause,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (provider.error == null)
                      AudioVisualizer(
                        isPlaying: provider.isPlaying,
                        color: AppColors.primary,
                        barCount: 24,
                        width: 260,
                        height: 32,
                      ),
                  ],
                ),
              ),
              // Right half: Title + Controls + Error state
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTitle(context, channel),
                    const SizedBox(height: 16),
                    if (provider.error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildErrorPanel(context, provider, channel),
                      ),
                    const SizedBox(height: 16),
                    _buildControls(context, provider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorPanel(BuildContext context, AudioProvider provider, dynamic channel) {
    return Padding(
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
                  color: AppColors.onSurface,
                  fontSize: 12,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.onSurface, size: 20),
              onPressed: () => provider.playChannel(channel),
              tooltip: 'Thử lại',
            ),
          ],
        ),
      ),
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
                color: AppColors.onSurface, size: 32),
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
                    color: AppColors.onSurface,
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
                  color: AppColors.onSurface,
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
          color: AppColors.onSurface,
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
          color: AppColors.onSurface,
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(AudioProvider provider) {
    return Semantics(
      label: provider.isPlaying ? 'Tạm dừng' : 'Phát nhạc',
      button: true,
      child: BounceScaleWidget(
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
                    color: AppColors.onSurface,
                  ),
                )
              : Icon(
                  provider.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.onSurface,
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
      child: BounceScaleWidget(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.onSurface.withValues(alpha: 0.05),
            border: Border.all(
              color: AppColors.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}

// BounceScaleWidget is defined in mini_player.dart and imported via show clause above.
