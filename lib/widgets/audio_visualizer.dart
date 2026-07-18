import 'dart:math';

import 'package:flutter/material.dart';

/// Animated audio visualizer bars that animate when playing.
/// Creates a faux visualization effect with randomly animated bars.
class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int barCount;
  final double width;
  final double height;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.color = const Color(0xFFE94560),
    this.barCount = 28,
    this.width = 280,
    this.height = 60,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + _random.nextInt(500)),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.1 + _random.nextDouble() * 0.15,
        end: 0.4 + _random.nextDouble() * 0.6,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (final controller in _controllers) {
      Future.delayed(
        Duration(milliseconds: _random.nextInt(300)),
        () {
          if (mounted) controller.repeat(reverse: true);
        },
      );
    }
  }

  void _stopAnimations() {
    for (final controller in _controllers) {
      controller.animateTo(0.15,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut);
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = widget.width / (widget.barCount * 2);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: barWidth,
                height: widget.height * _animations[index].value,
                margin: EdgeInsets.symmetric(horizontal: barWidth * 0.3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(barWidth / 2),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      widget.color.withValues(alpha: 0.6),
                      widget.color,
                      widget.color.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: widget.isPlaying
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Small playing indicator (3 bars) for channel cards
class PlayingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const PlayingIndicator({
    super.key,
    this.color = const Color(0xFFE94560),
    this.size = 16,
  });

  @override
  State<PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    final random = Random();

    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + random.nextInt(200)),
      )..repeat(reverse: true),
    );

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, _) {
            return Container(
              width: widget.size * 0.2,
              height: widget.size * _animations[i].value,
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.size * 0.1),
              ),
            );
          },
        );
      }),
    );
  }
}
