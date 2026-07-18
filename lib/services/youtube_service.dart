import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_explode_dart/src/reverse_engineering/youtube_http_client.dart' as ythtp;
import 'package:youtube_explode_dart/src/videos/video_controller.dart';
import 'package:youtube_explode_dart/src/videos/youtube_api_client.dart';
import 'package:flutter/foundation.dart';
import '../models/lofi_channel.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Hardcoded playlist from lofi.py
  static const String playlistId = 'PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L';

  /// Fetches all videos from the playlist using InnerTube browse API.
  /// This is the Dart equivalent of yt_dlp's `extract_flat: True` configuration.
  Future<List<LofiChannel>> fetchPlaylist() async {
    final url = Uri.parse(
      'https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8',
    );

    final body = {
      'browseId': 'VL$playlistId',
      'context': {
        'client': {
          'clientName': 'WEB',
          'clientVersion': '2.20240101.01.00',
          'hl': 'en',
          'gl': 'US',
        }
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch playlist via InnerTube API: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final List<LofiChannel> channels = [];

      final contents = data['contents']?['twoColumnBrowseResultsRenderer']?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']?['contents']?[0]?['itemSectionRenderer']?['contents'];

      if (contents != null) {
        for (var item in contents) {
          final lockup = item['lockupViewModel'];
          if (lockup != null) {
            final videoId = lockup['contentId'];
            final title = lockup['metadata']?['lockupMetadataViewModel']?['title']?['content'] ?? 'Unknown Title';
            if (videoId != null) {
              channels.add(LofiChannel(
                title: title,
                videoId: videoId,
              ));
            }
          }
        }
        return channels;
      }
      throw Exception('Could not find playlist content in JSON response');
    } catch (e) {
      throw Exception('Error fetching playlist: $e');
    }
  }

  /// Extracts the direct audio stream URL for a video.
  /// For live streams, we fetch the player response from the ANDROID client,
  /// matching python's yt_dlp option `--extractor-args youtube:player_client=android`
  /// which returns the correct HLS (.m3u8) manifest URL.
  Future<String> getAudioStreamUrl(String videoId) async {
    final httpClient = ythtp.YoutubeHttpClient();
    final controller = VideoController(httpClient);

    try {
      // 1. Try to get playerResponse using the ANDROID client context (like yt-dlp -f bestaudio/worst)
      final response = await controller.getPlayerResponse(VideoId(videoId), YoutubeApiClient.android);
      
      // If it is a live video, extract HLS stream
      if (response.isLive && response.hlsManifestUrl != null) {
        return response.hlsManifestUrl!;
      }
    } catch (e) {
      debugPrint('Android playerResponse stream extraction failed: $e. Falling back to standard YoutubeExplode streams.');
    } finally {
      httpClient.close();
    }

    // 2. Fallback for non-live videos (regular stream extraction)
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(VideoId(videoId));
      final audioStreams = manifest.audioOnly;
      if (audioStreams.isNotEmpty) {
        return audioStreams.withHighestBitrate().url.toString();
      }
      throw Exception('No audio streams available');
    } catch (e) {
      throw Exception('Cannot extract audio stream: $e');
    }
  }

  void dispose() {
    _yt.close();
  }
}
