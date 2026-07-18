import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/lofi_channel.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Hardcoded playlist from lofi.py
  static const String playlistId = 'PL6NdkXsPL07Il2hEQGcLI4dg_LTg7xA2L';

  /// Fetches all videos from the hardcoded playlist.
  /// Equivalent to `playlist()` in lofi.py using yt_dlp.extract_info().
  Future<List<LofiChannel>> fetchPlaylist() async {
    try {
      final videos =
          await _yt.playlists.getVideos(PlaylistId(playlistId)).toList();
      return videos
          .map((video) => LofiChannel(
                title: video.title,
                videoId: video.id.value,
                duration: video.duration,
              ))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Extracts the direct audio stream URL for a video.
  /// Equivalent to the yt-dlp subprocess in `live()` of lofi.py
  /// that extracts 'bestaudio/worst' format.
  Future<String> getAudioStreamUrl(String videoId) async {
    try {
      // Try regular audio stream first (like yt-dlp -f bestaudio)
      final manifest =
          await _yt.videos.streamsClient.getManifest(VideoId(videoId));
      final audioStreams = manifest.audioOnly;
      if (audioStreams.isNotEmpty) {
        return audioStreams.withHighestBitrate().url.toString();
      }
      throw Exception('No audio streams available');
    } catch (_) {
      // Fallback: try HLS for live streams
      try {
        final url = await _yt.videos.streamsClient
            .getHttpLiveStreamUrl(VideoId(videoId));
        return url.toString();
      } catch (e) {
        throw Exception('Cannot extract audio stream: $e');
      }
    }
  }

  void dispose() {
    _yt.close();
  }
}
