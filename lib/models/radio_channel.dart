class RadioChannel {
  final String title;
  final String videoId;
  final Duration? duration;

  const RadioChannel({
    required this.title,
    required this.videoId,
    this.duration,
  });

  /// Low-quality thumbnail for cards (320x180, ~8-15KB)
  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg';

  /// Medium-quality thumbnail for player screen (480x360, ~15-30KB)
  String get maxThumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  bool get isLive => duration == null || duration == Duration.zero;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioChannel && videoId == other.videoId;

  @override
  int get hashCode => videoId.hashCode;
}
