import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final storage = FlutterSecureStorage();
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? user;

  Future<bool> register(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.dio.post('/auth/register', data: data);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password, BuildContext context) async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    final response = await ApiService.dio.post('/auth/login', data: {
      "email": email,
      "password": password,
    });

    await storage.write(key: 'token', value: response.data['token']);
    user = response.data['user'];

    if (user != null && user!['id'] != null) {
      SocketService.connect(context, user!['id'].toString());
    }

    isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    errorMessage = "Невірний email або пароль";
    isLoading = false;
    notifyListeners();
    return false;
  }
}

  Future<void> logout() async {
    await storage.delete(key: 'token');
    user = null;
    SocketService.disconnect();
    notifyListeners();
  }
}