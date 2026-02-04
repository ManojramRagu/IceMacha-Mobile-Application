import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/products_cache.json';
  }

  Future<File> saveProducts(String json) async {
    final path = await _getFilePath();
    final file = File(path);
    return file.writeAsString(json);
  }

  Future<String?> readProducts() async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      // In a real app, you might use a logging service here
      print('Error reading product cache: $e');
      return null;
    }
  }
}
