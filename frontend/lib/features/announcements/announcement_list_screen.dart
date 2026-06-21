import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'announcement_provider.dart';
import 'create_announcement_screen.dart';
import 'announcement_detail_screen.dart';
import '../../features/auth/auth_provider.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnnouncementProvider>(context, listen: false).fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnnouncementProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isTeacher = auth.user?['role'] == 'teacher';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Оголошення"),
        backgroundColor: const Color(0xFF4A6CF7),
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.refresh),
    onPressed: () => provider.fetchAnnouncements(),
  ),
  IconButton(
    icon: const Icon(Icons.person),
    onPressed: () {
      Navigator.pushNamed(context, '/profile');
    },
  ),
],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.announcements.isEmpty
              ? const Center(child: Text("Поки немає оголошень"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.announcements.length,
                  itemBuilder: (context, index) {
                    final ann = provider.announcements[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(ann.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text("Від: ${ann.authorName}"),
                            Text(ann.createdAt.substring(0, 16)),
                            if (ann.subject != null) Text("Предмет: ${ann.subject}"),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnnouncementDetailScreen(announcement: ann),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: isTeacher
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF4A6CF7),
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()),
                );
                provider.fetchAnnouncements(); // оновити список після створення
              },
            )
          : null,
    );
  }
}