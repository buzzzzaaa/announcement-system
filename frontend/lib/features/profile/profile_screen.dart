import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Профіль")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 60)),
            const SizedBox(height: 20),
            Text(auth.user?['name'] ?? 'Користувач', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(auth.user?['role'] == 'teacher' ? 'Викладач' : 'Студент'),
            const SizedBox(height: 40),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Вийти"),
              onTap: () {
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}