import 'package:flutter/material.dart';
import '../../models/announcement.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import 'create_announcement_screen.dart';
import '../../services/api_service.dart';
import 'announcement_provider.dart';   

class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  Future<void> _deleteAnnouncement(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Видалити оголошення?"),
        content: const Text("Цю дію неможливо скасувати"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Скасувати")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Видалити", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final provider = Provider.of<AnnouncementProvider>(context, listen: false);
      bool success = await provider.deleteAnnouncement(announcement.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Оголошення успішно видалено")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Помилка: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthor = authProvider.user?['id'].toString() == announcement.authorName.toString() ||
                     authProvider.user?['name'] == announcement.authorName;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Деталі оголошення"),
        backgroundColor: const Color(0xFF4A6CF7),
        foregroundColor: Colors.white,
        actions: [
          if (isAuthor) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateAnnouncementScreen(announcementToEdit: announcement),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAnnouncement(context),
            ),
          ]
        ],
      ),
     body: SingleChildScrollView(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        announcement.title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        "Від: ${announcement.authorName} • ${announcement.createdAt.substring(0, 16)}",
        style: const TextStyle(color: Colors.grey),
      ),
      const SizedBox(height: 20),

      if (announcement.subject != null && announcement.subject!.isNotEmpty)
        Chip(label: Text(announcement.subject!)),

      const SizedBox(height: 16),
      Text(
        announcement.description,
        style: const TextStyle(fontSize: 16, height: 1.6),
      ),

      // ==================== БЛОК З ФАЙЛОМ ====================
      if (announcement.fileUrl != null)
        Card(
          margin: const EdgeInsets.only(top: 24),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.attach_file, color: Colors.blue, size: 40),
            title: const Text("Прикріплений файл", style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              announcement.fileUrl!.split('/').last,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: const Icon(Icons.download, color: Colors.blue),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Файл: ${announcement.fileUrl!.split('/').last}")),
              );
            },
          ),
        ),

      const SizedBox(height: 40),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A6CF7),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Зрозуміло", style: TextStyle(fontSize: 18)),
        ),
      ),
    ],
  ),
),
    );
  }
}