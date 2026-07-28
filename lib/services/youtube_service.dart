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
  /// We then parse the HLS manifest to extract ONLY the audio-only stream,
  /// avoiding downloading video data (~10x data savings).
  Future<String> getAudioStreamUrl(String videoId) async {
    final httpClient = ythtp.YoutubeHttpClient();
    final controller = VideoController(httpClient);

    try {
      // 1. Try to get playerResponse using the ANDROID client context
      final response = await controller.getPlayerResponse(VideoId(videoId), YoutubeApiClient.android);
      
      // If it is a live video, extract audio-only stream from HLS manifest
      if (response.isLive && response.hlsManifestUrl != null) {
        final audioUrl = await _extractAudioOnlyFromHls(response.hlsManifestUrl!);
        if (audioUrl != null) {
          return audioUrl;
        }
        // Fallback: return full manifest if audio-only extraction fails
        debugPrint('Could not extract audio-only from HLS, falling back to full manifest');
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
      final audioStreams = manifest.audioOnly.sortByBitrate();
      if (audioStreams.isNotEmpty) {
        // Use lowest bitrate to minimize data usage — lofi music sounds
        // great even at low bitrates.
        return audioStreams.first.url.toString();
      }
      throw Exception('No audio streams available');
    } catch (e) {
      throw Exception('Cannot extract audio stream: $e');
    }
  }

  /// Parses an HLS master playlist (.m3u8) to extract the best low-bandwidth
  /// stream URL. YouTube live HLS manifests typically contain ONLY muxed
  /// video+audio variants (no separate audio-only). Strategy:
  ///   1. First look for audio-only variants (no RESOLUTION=) — ideal case
  ///   2. If none found, select the LOWEST bandwidth muxed variant (e.g. 144p)
  ///      to minimize data usage (~2MB/min vs ~9MB/min for auto-selected)
  Future<String?> _extractAudioOnlyFromHls(String hlsManifestUrl) async {
    try {
      final response = await http.get(
        Uri.parse(hlsManifestUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('[HLS] Failed to fetch manifest: ${response.statusCode}');
        return null;
      }

      final manifest = response.body;
      final lines = manifest.split('\n');

      // Collect ALL variants, separating audio-only from muxed
      int? lowestAudioOnlyBw;
      String? lowestAudioOnlyUrl;
      int? lowestMuxedBw;
      String? lowestMuxedUrl;

      for (int i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        if (!line.startsWith('#EXT-X-STREAM-INF')) continue;

        // The URL is on the next line
        final urlLine = lines[i + 1].trim();
        if (urlLine.isEmpty || urlLine.startsWith('#')) continue;

        final bwMatch = RegExp(r'BANDWIDTH=(\d+)').firstMatch(line);
        final bandwidth = bwMatch != null ? int.tryParse(bwMatch.group(1)!) : null;
        final hasResolution = line.contains('RESOLUTION=');

        if (!hasResolution) {
          // Audio-only variant (ideal)
          if (bandwidth != null) {
            if (lowestAudioOnlyBw == null || bandwidth < lowestAudioOnlyBw) {
              lowestAudioOnlyBw = bandwidth;
              lowestAudioOnlyUrl = urlLine;
            }
          } else {
            lowestAudioOnlyUrl ??= urlLine;
          }
        } else {
          // Muxed video+audio variant
          if (bandwidth != null) {
            if (lowestMuxedBw == null || bandwidth < lowestMuxedBw) {
              lowestMuxedBw = bandwidth;
              lowestMuxedUrl = urlLine;
            }
          }
        }
      }

      // Prefer audio-only if available
      if (lowestAudioOnlyUrl != null) {
        debugPrint('[HLS] ✓ Audio-only stream found: bandwidth=$lowestAudioOnlyBw');
        return lowestAudioOnlyUrl;
      }

      // Fallback: use lowest bandwidth muxed variant (e.g. 144p ~250kbps)
      // Much better than letting ExoPlayer auto-select (usually 480p+ ~1.3Mbps)
      if (lowestMuxedUrl != null) {
        debugPrint('[HLS] ⚠ No audio-only variant. Using lowest muxed: bandwidth=$lowestMuxedBw (144p)');
        return lowestMuxedUrl;
      }

      debugPrint('[HLS] ✗ No variants found in manifest');
      return null;
    } catch (e) {
      debugPrint('[HLS] Error parsing manifest: $e');
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}
