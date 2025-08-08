import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class ProfilePhotoProvider extends ChangeNotifier {
  static const _kPrefKey = 'profile_photo_path';

  String? _imagePath;
  String? get imagePath => _imagePath;
  bool get hasImage =>
      _imagePath != null &&
      _imagePath!.isNotEmpty &&
      File(_imagePath!).existsSync();

  /// Call this once at app startup
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _imagePath = prefs.getString(_kPrefKey);
    notifyListeners();
  }

  /// Pick from gallery, copy into app docs dir, save path
  Future<void> pickAndSave() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    final savedPath = await _savePermanent(File(picked.path));
    await _persistPath(savedPath);
    _imagePath = savedPath;
    notifyListeners();
  }

  /// Remove photo
  Future<void> remove() async {
    if (hasImage) {
      try {
        File(_imagePath!).deleteSync();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefKey);
    _imagePath = null;
    notifyListeners();
  }

  Future<String> _savePermanent(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    // keep a stable filename so repeated picks overwrite (optional)
    final filename = 'profile${p.extension(file.path)}';
    final dest = File(p.join(dir.path, filename));
    await file.copy(dest.path);
    return dest.path;
  }

  Future<void> _persistPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefKey, path);
  }
}
