import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/announcements/announcement_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/announcements/announcement_list_screen.dart';
import 'features/profile/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
      ],
      child: MaterialApp(
        title: 'UniAnnounce',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        routes: {
          '/home': (context) => const AnnouncementListScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
