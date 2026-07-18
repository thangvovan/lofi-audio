import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/audio_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/channel_card.dart';
import '../widgets/mini_player.dart';
import '../widgets/space_nebula_bg.dart';

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

          // Particle background overlay
          Positioned.fill(
            child: Consumer<AudioProvider>(
              builder: (context, provider, _) {
                return SpaceNebulaBg(isPlaying: provider.isPlaying);
              },
            ),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: Consumer<AudioProvider>(
              builder: (context, provider, _) {
                return Column(
                  children: [
                    _buildHeader(context),
                    _buildOnboardingHint(context, provider),
                    const SizedBox(height: 8),
                    Expanded(
                      child: provider.isLoadingPlaylist
                          ? _buildShimmerGrid()
                          : (provider.error != null && provider.channels.isEmpty
                              ? _buildError(context, provider)
                              : _buildChannelGrid(context, provider)),
                    ),
                  ],
                );
              },
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
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                const Icon(Icons.headphones_rounded, color: AppColors.onSurface, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOFI RADIO',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: 1.5,
                        fontFamily: 'Outfit',
                        shadows: [
                          Shadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chill beats to relax & study',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inactiveText,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelGrid(BuildContext context, AudioProvider provider) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: provider.loadPlaylist,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
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

           return _FadeSlideEntrance(
            index: index,
            child: ChannelCard(
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
            ),
          );
        },
      ),
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
          baseColor: AppColors.surface,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                    color: AppColors.onSurface,
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
                foregroundColor: AppColors.onSurface,
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

  Widget _buildOnboardingHint(BuildContext context, AudioProvider provider) {
    if (provider.hasSeenOnboardingHint || provider.hasCurrentChannel) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: AppColors.secondary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Chọn một cuộn băng cassette để bắt đầu nghe nhạc lofi.',
                style: TextStyle(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.inactiveText, size: 16),
              onPressed: provider.dismissOnboardingHint,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Đóng gợi ý',
            ),
          ],
        ),
      ),
    );
  }
}

/// Staggered fade and slide-up entrance animation for grid items.
/// Bypasses animation if prefers-reduced-motion is requested.
class _FadeSlideEntrance extends StatefulWidget {
  final Widget child;
  final int index;

  const _FadeSlideEntrance({
    required this.child,
    required this.index,
  });

  @override
  State<_FadeSlideEntrance> createState() => _FadeSlideEntranceState();
}

class _FadeSlideEntranceState extends State<_FadeSlideEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    // Stagger entry delay based on item index (capped at 10 items to prevent lag)
    final staggerIndex = widget.index.clamp(0, 10);
    final delay = Duration(milliseconds: staggerIndex * 40);
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect OS-level reduced motion preferences
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: FractionalTranslation(
            translation: _slideAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
