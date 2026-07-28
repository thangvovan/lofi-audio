import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/lofi_channel.dart';
import '../services/audio_service.dart';
import '../services/youtube_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioService audioService;
  final YoutubeService youtubeService;

  List<LofiChannel> _channels = [];
  LofiChannel? _currentChannel;
  int _currentIndex = -1;
  bool _isLoadingPlaylist = true;
  bool _isLoadingStream = false;
  String? _error;

  StreamSubscription? _playerStateSub;
  bool _hasSeenOnboardingHint = false;

  // Getters
  List<LofiChannel> get channels => _channels;
  LofiChannel? get currentChannel => _currentChannel;
  int get currentIndex => _currentIndex;
  bool get isLoadingPlaylist => _isLoadingPlaylist;
  bool get isLoadingStream => _isLoadingStream;
  String? get error => _error;
  AudioPlayer get player => audioService.player;
  bool get isPlaying => audioService.player.playing;
  bool get hasCurrentChannel => _currentChannel != null;
  bool get hasSeenOnboardingHint => _hasSeenOnboardingHint;

  AudioProvider({required this.audioService, required this.youtubeService}) {
    // Listen for player state changes to update UI
    _playerStateSub = audioService.player.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  /// Load the hardcoded playlist (once only — skips if already loaded)
  Future<void> loadPlaylist() async {
    // Only load once to minimize data usage
    if (_channels.isNotEmpty) return;

    _isLoadingPlaylist = true;
    _error = null;
    notifyListeners();

    try {
      _channels = await youtubeService.fetchPlaylist();
      _isLoadingPlaylist = false;
    } catch (e) {
      _error = 'Không thể tải playlist: $e';
      _isLoadingPlaylist = false;
    }
    notifyListeners();
  }

  /// Force reload playlist
  Future<void> retryLoadPlaylist() async {
    _channels = [];
    await loadPlaylist();
  }

  /// Play a specific channel
  Future<void> playChannel(LofiChannel channel) async {
    _isLoadingStream = true;
    _currentChannel = channel;
    _currentIndex = _channels.indexOf(channel);
    _error = null;
    _hasSeenOnboardingHint = true; // Auto-dismiss hint on first play
    notifyListeners();

    try {
      final url = await youtubeService.getAudioStreamUrl(channel.videoId);
      await audioService.setUrl(url);

      await audioService.play();
      _isLoadingStream = false;
    } catch (e) {
      _error = 'Không thể phát: $e';
      _isLoadingStream = false;
    }
    notifyListeners();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (audioService.player.playing) {
      await audioService.pause();
    } else {
      await audioService.play();
    }
    notifyListeners();
  }

  double _lastVolume = 1.0;

  /// Get current volume (0.0 to 1.0)
  double get volume => audioService.player.volume;
  bool get isMuted => volume <= 0.001;

  /// Set volume level (clamped between 0.0 and 1.0)
  Future<void> setVolume(double newVolume) async {
    final clampedVolume = newVolume.clamp(0.0, 1.0);
    await audioService.player.setVolume(clampedVolume);
    if (clampedVolume > 0) {
      _lastVolume = clampedVolume;
    }
    notifyListeners();
  }

  /// Toggle mute/unmute
  Future<void> toggleMute() async {
    if (isMuted) {
      await setVolume(_lastVolume > 0 ? _lastVolume : 0.8);
    } else {
      _lastVolume = volume;
      await setVolume(0.0);
    }
  }

  /// Increase volume by step (default 0.1)
  Future<void> volumeUp([double step = 0.1]) async {
    await setVolume(volume + step);
  }

  /// Decrease volume by step (default 0.1)
  Future<void> volumeDown([double step = 0.1]) async {
    await setVolume(volume - step);
  }

  /// Stop playback
  Future<void> stop() async {
    await audioService.stop();
    _currentChannel = null;
    _currentIndex = -1;
    notifyListeners();
  }

  void dismissOnboardingHint() {
    _hasSeenOnboardingHint = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    youtubeService.dispose();
    super.dispose();
  }
}
