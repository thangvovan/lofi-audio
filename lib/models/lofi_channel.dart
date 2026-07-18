class LofiChannel {
  final String title;
  final String videoId;
  final Duration? duration;

  const LofiChannel({
    required this.title,
    required this.videoId,
    this.duration,
  });

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  String get maxThumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

  bool get isLive => duration == null || duration == Duration.zero;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LofiChannel &&
          runtimeType == other.runtimeType &&
          videoId == other.videoId;

  @override
  int get hashCode => videoId.hashCode;
}
