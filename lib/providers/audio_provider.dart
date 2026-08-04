import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/radio_channel.dart';
import '../services/audio_service.dart';
import '../services/youtube_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioService audioService;
  final YoutubeService youtubeService;

  List<RadioChannel> _channels = [];
  RadioChannel? _currentChannel;
  int _currentIndex = -1;
  bool _isLoadingPlaylist = true;
  bool _isLoadingStream = false;
  String? _error;

  StreamSubscription? _playerStateSub;

  // Getters
  List<RadioChannel> get channels => _channels;
  RadioChannel? get currentChannel => _currentChannel;
  int get currentIndex => _currentIndex;
  bool get isLoadingPlaylist => _isLoadingPlaylist;
  bool get isLoadingStream => _isLoadingStream;
  String? get error => _error;
  AudioPlayer get player => audioService.player;
  double get volume => audioService.player.volume;
  bool get isPlaying => audioService.player.playing;
  bool get hasCurrentChannel => _currentChannel != null;

  AudioProvider({required this.audioService, required this.youtubeService}) {
    // Listen for player state changes to update UI
    _playerStateSub = audioService.player.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  // Load the hardcoded playlist
  Future<void> loadPlaylist() async {
    _isLoadingPlaylist = true;
    _error = null;
    notifyListeners();

    try {
      _channels = await youtubeService.fetchPlaylist();
      _isLoadingPlaylist = false;
      notifyListeners();
    } catch (e) {
      _error = 'Không thể tải playlist';
      _isLoadingPlaylist = false;
      notifyListeners();
    }
  }

  // Force reload playlist
  Future<void> retryLoadPlaylist() async {
    _channels = [];
    await loadPlaylist();
  }

  // Play a specific channel
  Future<void> playChannel(RadioChannel channel) async {
    _currentChannel = channel;
    _currentIndex = _channels.indexOf(channel);
    _isLoadingStream = true;
    _error = null;
    notifyListeners();

    try {
      final url = await youtubeService.getAudioStreamUrl(channel.videoId);
      await audioService.setUrl(url);
      _isLoadingStream = false;
      notifyListeners();

      audioService.play();
    } catch (e) {
      _error = 'Không thể phát';
      _isLoadingStream = false;
      notifyListeners();
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (audioService.player.playing) {
      await audioService.pause();
    } else {
      await audioService.play();
    }
    notifyListeners();
  }

  // Set volume level
  Future<void> setVolume(double newVolume) async {
    final clampedVolume = newVolume.clamp(0.0, 1.0);
    await audioService.player.setVolume(clampedVolume);
    notifyListeners();
  }

  // Increase volume by step
  Future<void> volumeUp([double step = 0.1]) async {
    await setVolume(volume + step);
  }

  // Decrease volume by step
  Future<void> volumeDown([double step = 0.1]) async {
    await setVolume(volume - step);
  }

  // Stop playback
  Future<void> stop() async {
    await audioService.stop();
    _currentChannel = null;
    _currentIndex = -1;
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    youtubeService.dispose();
    super.dispose();
  }
}
