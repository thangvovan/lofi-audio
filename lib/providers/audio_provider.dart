import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/lofi_channel.dart';
import '../services/audio_handler.dart';
import '../services/youtube_service.dart';

class AudioProvider extends ChangeNotifier {
  final LofiAudioHandler audioHandler;
  final YoutubeService youtubeService;

  List<LofiChannel> _channels = [];
  LofiChannel? _currentChannel;
  int _currentIndex = -1;
  bool _isLoadingPlaylist = true;
  bool _isLoadingStream = false;
  String? _error;

  StreamSubscription? _skipNextSub;
  StreamSubscription? _skipPrevSub;
  StreamSubscription? _playerStateSub;
  bool _hasSeenOnboardingHint = false;

  // Getters
  List<LofiChannel> get channels => _channels;
  LofiChannel? get currentChannel => _currentChannel;
  int get currentIndex => _currentIndex;
  bool get isLoadingPlaylist => _isLoadingPlaylist;
  bool get isLoadingStream => _isLoadingStream;
  String? get error => _error;
  AudioPlayer get player => audioHandler.player;
  bool get isPlaying => audioHandler.player.playing;
  bool get hasCurrentChannel => _currentChannel != null;
  bool get hasSeenOnboardingHint => _hasSeenOnboardingHint;

  AudioProvider({
    required this.audioHandler,
    required this.youtubeService,
  }) {
    // Listen for notification skip controls
    _skipNextSub = audioHandler.onSkipNext.listen((_) => next());
    _skipPrevSub = audioHandler.onSkipPrevious.listen((_) => previous());

    // Listen for player state changes to update UI
    _playerStateSub = audioHandler.player.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  /// Load the hardcoded playlist
  Future<void> loadPlaylist() async {
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
      await audioHandler.setUrl(url);

      await audioHandler.play();
      _isLoadingStream = false;
    } catch (e) {
      _error = 'Không thể phát: $e';
      _isLoadingStream = false;
    }
    notifyListeners();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (audioHandler.player.playing) {
      await audioHandler.pause();
    } else {
      await audioHandler.play();
    }
    notifyListeners();
  }

  /// Play next channel in playlist
  Future<void> next() async {
    if (_channels.isEmpty) return;
    final nextIndex = (_currentIndex + 1) % _channels.length;
    await playChannel(_channels[nextIndex]);
  }

  /// Play previous channel in playlist
  Future<void> previous() async {
    if (_channels.isEmpty) return;
    final prevIndex =
        (_currentIndex - 1 + _channels.length) % _channels.length;
    await playChannel(_channels[prevIndex]);
  }

  /// Stop playback
  Future<void> stop() async {
    await audioHandler.stop();
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
    _skipNextSub?.cancel();
    _skipPrevSub?.cancel();
    _playerStateSub?.cancel();
    youtubeService.dispose();
    super.dispose();
  }
}
