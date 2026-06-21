import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../models/announcement.dart';

class AnnouncementProvider extends ChangeNotifier {
  List<Announcement> announcements = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchAnnouncements() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.dio.get('/announcements');
      announcements = (response.data as List)
          .map((item) => Announcement.fromJson(item))
          .toList();
    } catch (e) {
      errorMessage = e.toString();
      print("Помилка завантаження оголошень: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // Додаємо методи для оновлення після змін
  Future<bool> createAnnouncement(Map<String, dynamic> data, {dynamic file}) async {
    try {
      FormData formData = FormData.fromMap({
        ...data,
        if (file != null) "file": await MultipartFile.fromFile(file.path, filename: file.name),
      });

      await ApiService.dio.post('/announcements', data: formData);
      await fetchAnnouncements();  
      return true;
    } catch (e) {
      print("Помилка створення: $e");
      return false;
    }
  }

  Future<bool> updateAnnouncement(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.dio.put('/announcements/$id', data: data);
      await fetchAnnouncements();  
      return true;
    } catch (e) {
      print("Помилка оновлення: $e");
      return false;
    }
  }

  Future<bool> deleteAnnouncement(int id) async {
    try {
      await ApiService.dio.delete('/announcements/$id');
      await fetchAnnouncements();   
      return true;
    } catch (e) {
      print("Помилка видалення: $e");
      return false;
    }
  }
}