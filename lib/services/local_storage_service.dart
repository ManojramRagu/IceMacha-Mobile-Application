import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<File> saveData(String fileName, String content) async {
    final path = await _getFilePath(fileName);
    final file = File(path);
    return file.writeAsString(content);
  }

  Future<String?> readData(String fileName) async {
    try {
      final path = await _getFilePath(fileName);
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      // In a real app, you might use a logging service here
      print('Error reading file: $e');
      return null;
    }
  }
}
