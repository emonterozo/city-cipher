class Promotion {
  final String id;
  final String title;
  final String label;
  final String banner;
  final String url;

  Promotion({
    required this.id,
    required this.title,
    required this.label,
    required this.banner,
    required this.url,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      label: json['label'] ?? '',
      banner: json['banner'] ?? '',
      url: json['url'] ?? '',
    );
  }
}