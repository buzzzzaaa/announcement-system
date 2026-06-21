import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'register_screen.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ApiService.init(); // ініціалізуємо Dio
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 100, color: Color(0xFF4A6CF7)),
            const SizedBox(height: 20),
            const Text(
              "Вхід у систему",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Пароль",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6CF7),
                ),
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                       print("BUTTON PRESSED");
                        bool success = await authProvider.login(
                          _emailController.text,
                          _passwordController.text,
                          context,           
                        );
                        if (success) {
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(authProvider.errorMessage ?? "Помилка")),
                          );
                        }
                      },
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Увійти", style: TextStyle(fontSize: 18)),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text("Немає акаунту? Зареєструватися"),
            ),
          ],
        ),
      ),
    );
  }
}