import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String selectedRole = 'student';
  String? selectedGroup;
  int? selectedCourse;

  final List<String> groups = ['1КІ1', '1КІ2', '1КІ3', '2КІ1', '2КІ2', '2КІ3', '3КІ1', '3КІ2', '3КІ3', '4КІ1', '4КІ2', '4КІ3'];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Реєстрація")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "ПІБ"),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Пароль"),
            ),
            const SizedBox(height: 16),

            // Вибір ролі
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: "Роль"),
              items: const [
                DropdownMenuItem(value: 'student', child: Text("Студент")),
                DropdownMenuItem(value: 'teacher', child: Text("Викладач")),
              ],
              onChanged: (value) {
                setState(() => selectedRole = value!);
              },
            ),
            const SizedBox(height: 16),

            if (selectedRole == 'student') ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Група"),
                items: groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (value) => setState(() => selectedGroup = value),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Курс"),
                items: [1, 2, 3, 4].map((c) => DropdownMenuItem(value: c, child: Text("$c курс"))).toList(),
                onChanged: (value) => setState(() => selectedCourse = value),
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A6CF7)),
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        bool success = await authProvider.register({
                          "name": _nameController.text,
                          "email": _emailController.text,
                          "password": _passwordController.text,
                          "role": selectedRole,
                          "group": selectedGroup,
                          "course": selectedCourse,
                        });

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Реєстрація успішна! Тепер увійдіть")),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(authProvider.errorMessage ?? "Помилка реєстрації")),
                          );
                        }
                      },
                child: const Text("Зареєструватися", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}