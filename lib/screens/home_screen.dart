import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/audio_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/channel_card.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF16213E), // Keeping this gradient base for rich atmosphere, or we can use AppColors.tertiary
                  AppColors.background,
                  AppColors.background,
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 8),
                Expanded(
                  child: Consumer<AudioProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoadingPlaylist) {
                        return _buildShimmerGrid();
                      }
                      if (provider.error != null &&
                          provider.channels.isEmpty) {
                        return _buildError(context, provider);
                      }
                      return _buildChannelGrid(context, provider);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Mini player overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const MiniPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE94560), Color(0xFF533483)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE94560).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                const Icon(Icons.headphones_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lofi Radio',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chill beats to relax & study',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8D8DAA),
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
          // Refresh button
          Consumer<AudioProvider>(
            builder: (context, provider, _) {
              return IconButton(
                onPressed:
                    provider.isLoadingPlaylist ? null : provider.loadPlaylist,
                icon: provider.isLoadingPlaylist
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF8D8DAA),
                        ),
                      )
                    : const Icon(Icons.refresh_rounded,
                        color: Color(0xFF8D8DAA)),
                tooltip: 'Tải lại',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChannelGrid(BuildContext context, AudioProvider provider) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        // Extra padding for mini player
        provider.hasCurrentChannel
            ? MediaQuery.of(context).padding.bottom + 90
            : MediaQuery.of(context).padding.bottom + 16,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 16 / 13,
      ),
      itemCount: provider.channels.length,
      itemBuilder: (context, index) {
        final channel = provider.channels[index];
        final isCurrentlyPlaying = provider.currentChannel == channel;

        return ChannelCard(
          channel: channel,
          isCurrentlyPlaying: isCurrentlyPlaying,
          isPlaying: isCurrentlyPlaying && provider.isPlaying,
          onTap: () {
            if (isCurrentlyPlaying) {
              provider.togglePlayPause();
            } else {
              provider.playChannel(channel);
            }
          },
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 16 / 13,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFF1A1A2E),
          highlightColor: const Color(0xFF2A2A4E),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, AudioProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Không thể tải playlist',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kiểm tra kết nối mạng và thử lại',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inactiveText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.loadPlaylist,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
