class Announcement {
  final int id;
  final String title;
  final String description;
  final String authorName;
  final String createdAt;
  final String? fileUrl;
  final String targetType;
  final String? targetValue;
  final String? subject;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.createdAt,
    this.fileUrl,
    required this.targetType,
    this.targetValue,
    this.subject,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      authorName: json['author_name'] ?? 'Викладач',
      createdAt: json['created_at'],
      fileUrl: json['file_url'],
      targetType: json['target_type'],
      targetValue: json['target_value'],
      subject: json['subject'],
    );
  }
}