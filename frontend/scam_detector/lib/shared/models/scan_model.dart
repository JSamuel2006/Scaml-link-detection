class ScanModel {
  final int id;
  final String url;
  final String result;
  final double score;
  final String platform;
  final String createdAt;

  ScanModel({
    required this.id,
    required this.url,
    required this.result,
    required this.score,
    required this.platform,
    required this.createdAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) => ScanModel(
        id: json['id'],
        url: json['url'],
        result: json['result'],
        score: (json['score'] as num).toDouble(),
        platform: json['platform'] ?? 'manual',
        createdAt: json['created_at'] ?? '',
      );
}
