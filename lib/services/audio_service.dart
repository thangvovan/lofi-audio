import 'dart:async';

import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  bool get playing => _player.playing;

  // Set the audio source URL
  Future<void> setUrl(String url) async {
    await _player.setUrl(url);
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> dispose() async {
    await _player.dispose();
  }
}
