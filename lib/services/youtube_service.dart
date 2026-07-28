import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/radio_channel.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  // Hardcoded playlist from lofi.py
  static const String playlistId = 'PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L';

  // Fetches all videos from the playlist using InnerTube browse API.
  Future<List<RadioChannel>> fetchPlaylist() async {
    final url = Uri.parse(
      'https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8',
    );

    final headers = {
      'Content-Type': 'application/json',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    };

    final body = {
      'browseId': 'VL$playlistId',
      'context': {
        'client': {
          'clientName': 'WEB',
          'clientVersion': '2.20240101.01.00',
          'hl': 'en',
          'gl': 'US',
        },
      },
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception();
      }

      final data = json.decode(response.body);
      final List<RadioChannel> channels = [];

      final contents =
          data['contents']?['twoColumnBrowseResultsRenderer']?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']?['contents']?[0]?['itemSectionRenderer']?['contents'];

      if (contents == null) {
        throw Exception();
      }

      for (var item in contents) {
        final lockup = item['lockupViewModel'];
        if (lockup != null) {
          final videoId = lockup['contentId'];
          final title =
              lockup['metadata']?['lockupMetadataViewModel']?['title']?['content'] ??
              'Unknown Title';
          if (videoId != null) {
            channels.add(RadioChannel(title: title, videoId: videoId));
          }
        }
      }
      return channels;
    } catch (e) {
      throw Exception('Error fetching playlist');
    }
  }

  // Extracts the direct audio stream URL for a video
  Future<String> getAudioStreamUrl(String videoId) async {
    final httpClient = YoutubeHttpClient();

    try {
      // Fetch live HLS stream manifest URL using Android client context
      final api = YoutubeApiClient.android;
      final payload = api.payload;
      final userAgent = payload['context']?['client']?['userAgent'] as String?;

      final body = {...payload, 'videoId': videoId};
      final Map<String, String> headers = {
        'User-Agent': ?userAgent,
        'X-Youtube-Client-Name': payload['context']!['client']!['clientName'],
        'X-Youtube-Client-Version':
            payload['context']!['client']!['clientVersion'],
        'Origin': 'https://www.youtube.com',
        'Sec-Fetch-Mode': 'navigate',
        'Content-Type': 'application/json',
        ...api.headers,
      };

      final responseStr = await httpClient.postString(
        api.apiUrl,
        body: body,
        headers: headers,
      );

      final data = json.decode(responseStr);
      final String? hlsManifestUrl = data['streamingData']?['hlsManifestUrl'];

      if (hlsManifestUrl == null || hlsManifestUrl.isEmpty) {
        throw Exception();
      }

      final audioUrl = await _extractAudioOnlyFromHls(hlsManifestUrl);
      return audioUrl ?? hlsManifestUrl;
    } catch (e) {
      // Fallback for non-live videos
      final manifest = await _yt.videos.streamsClient.getManifest(
        VideoId(videoId),
      );
      final audioStreams = manifest.audioOnly.sortByBitrate();
      if (audioStreams.isNotEmpty) {
        // Use lowest bitrate to minimize data usage
        return audioStreams.first.url.toString();
      }
      throw Exception('Cannot extract audio stream');
    } finally {
      httpClient.close();
    }
  }

  // Parses an HLS master playlist to extract the best low-bandwidth stream URL
  Future<String?> _extractAudioOnlyFromHls(String hlsManifestUrl) async {
    try {
      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
      };

      final response = await http.get(
        Uri.parse(hlsManifestUrl),
        headers: headers,
      );

      if (response.statusCode != 200) {
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

        final urlLine = lines[i + 1].trim();
        if (urlLine.isEmpty || urlLine.startsWith('#')) continue;

        final bwMatch = RegExp(r'BANDWIDTH=(\d+)').firstMatch(line);
        final bandwidth = bwMatch != null
            ? int.tryParse(bwMatch.group(1)!)
            : null;
        final hasResolution = line.contains('RESOLUTION=');

        if (!hasResolution) {
          // Audio-only variant
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
        return lowestAudioOnlyUrl;
      }

      // Use lowest bandwidth muxed variant
      if (lowestMuxedUrl != null) {
        return lowestMuxedUrl;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}
