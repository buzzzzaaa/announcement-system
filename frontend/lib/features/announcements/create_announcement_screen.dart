import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'announcement_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/announcement.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final Announcement? announcementToEdit;

  const CreateAnnouncementScreen({super.key, this.announcementToEdit});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();

  String targetType = 'all';
  int? selectedCourse;
  String? selectedGroup;

  PlatformFile? pickedFile;
  bool isEditing = false;

  final List<String> groups = ['1КІ1', '1КІ2', '1КІ3', '2КІ1', '2КІ2', '2КІ3', '3КІ1', '3КІ2', '3КІ3', '4КІ1', '4КІ2', '4КІ3'];

  @override
  void initState() {
    super.initState();
    isEditing = widget.announcementToEdit != null;

    if (isEditing) {
      final ann = widget.announcementToEdit!;
      _titleController.text = ann.title;
      _descriptionController.text = ann.description;
      _subjectController.text = ann.subject ?? '';
      targetType = ann.targetType;
      selectedCourse = ann.targetValue != null ? int.tryParse(ann.targetValue!) : null;
      selectedGroup = ann.targetValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnnouncementProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Редагувати оголошення" : "Створити оголошення"),
        backgroundColor: const Color(0xFF4A6CF7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Назва", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Предмет", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: const InputDecoration(labelText: "Опис", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            const Text("Кому відправити:", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: targetType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'all', child: Text("Усім студентам")),
                DropdownMenuItem(value: 'course', child: Text("За курсом")),
                DropdownMenuItem(value: 'group', child: Text("За групою")),
              ],
              onChanged: (value) {
                setState(() {
                  targetType = value!;
                  selectedCourse = null;
                  selectedGroup = null;
                });
              },
            ),
            const SizedBox(height: 16),

            if (targetType == 'course')
              DropdownButtonFormField<int>(
                value: selectedCourse,
                decoration: const InputDecoration(labelText: "Курс", border: OutlineInputBorder()),
                items: [1,2,3,4].map((c) => DropdownMenuItem(value: c, child: Text("$c курс"))).toList(),
                onChanged: (val) => setState(() => selectedCourse = val),
              ),

                        if (targetType == 'group')
              DropdownButtonFormField<String>(
                value: selectedGroup,
                decoration: const InputDecoration(labelText: "Група", border: OutlineInputBorder()),
                items: groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => selectedGroup = val),
              ),

            const SizedBox(height: 25),

            // ==================== КНОПКА ПРИКРІПЛЕННЯ ФАЙЛУ ====================
            ElevatedButton.icon(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
                );

                if (result != null) {
                  setState(() {
                    pickedFile = result.files.first;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Файл прикріплено: ${pickedFile!.name}")),
                  );
                }
              },
              icon: const Icon(Icons.attach_file),
              label: Text(pickedFile == null 
                  ? "Прикріпити файл (PDF, фото...)" 
                  : "Файл: ${pickedFile!.name}"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            if (pickedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Розмір: ${(pickedFile!.size / 1024).toStringAsFixed(1)} KB",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 30),

          const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A6CF7)),
                onPressed: () async {
                  Map<String, dynamic> data = {
                    "title": _titleController.text,
                    "description": _descriptionController.text,
                    "subject": _subjectController.text,
                    "target_type": targetType,
                    "target_value": targetType == 'course' 
                        ? selectedCourse?.toString() 
                        : targetType == 'group' 
                            ? selectedGroup 
                            : null,
                  };

                  bool success = await provider.createAnnouncement(data, file: pickedFile);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? "Зміни збережено!" : "Оголошення опубліковано!")),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Помилка при збереженні")),
                    );
                  }
                },
                child: Text(isEditing ? "Зберегти зміни" : "Опублікувати", style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}