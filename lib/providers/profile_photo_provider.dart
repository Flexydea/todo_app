import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:hive/hive.dart';

class ProfilePhotoProvider extends ChangeNotifier {
  /// Box where we store the ID of the currently logged-in user.
  Box get _settings => Hive.box('settingsBox');

  /// Holds the full local path to the active user's profile image
  String? _imagePath;

  /// Public getter for widgets
  String? get imagePath => _imagePath;

  /// True if we have a valid, existing file
  bool get hasImage =>
      _imagePath != null &&
      _imagePath!.isNotEmpty &&
      File(_imagePath!).existsSync();

  /// Get the current user's Hive key (int) from settings
  int? get _currentUserKey => _settings.get('currentUser') as int?;

  /// Builds the SharedPreferences key for this specific user
  String get _prefKeyForUser =>
      _currentUserKey != null ? 'profile_photo_path_${_currentUserKey!}' : '';

  /// Load the saved photo path for the **current user**.
  /// Call this:
  /// - At app startup
  /// - After signup/login
  Future<void> loadForCurrentUser() async {
    if (_currentUserKey == null) {
      _imagePath = null;
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _imagePath = prefs.getString(_prefKeyForUser);
    notifyListeners();
  }

  /// Pick an image from the gallery, save it into app documents folder,
  /// persist the path **per user**, and update UI.
  Future<void> pickAndSave() async {
    if (_currentUserKey == null) return;

    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    final savedPath = await _savePermanent(File(picked.path));
    await _persistPath(savedPath);
    _imagePath = savedPath;
    notifyListeners();
  }

  /// Remove the current user's profile photo from disk and prefs.
  Future<void> remove() async {
    if (hasImage) {
      try {
        File(_imagePath!).deleteSync();
      } catch (_) {
        // ignore delete errors
      }
    }
    final prefs = await SharedPreferences.getInstance();
    if (_prefKeyForUser.isNotEmpty) {
      await prefs.remove(_prefKeyForUser);
    }
    _imagePath = null;
    notifyListeners();
  }

  /// Copy the picked file into app's documents directory.
  /// We name the file using the user's key so each user has a separate file.
  Future<String> _savePermanent(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = 'profile_${_currentUserKey}${p.extension(file.path)}';
    final dest = File(p.join(dir.path, filename));
    await file.copy(dest.path);
    return dest.path;
  }

  /// Save the file path to SharedPreferences for the current user.
  Future<void> _persistPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    if (_prefKeyForUser.isNotEmpty) {
      await prefs.setString(_prefKeyForUser, path);
    }
  }

  /// Clear only in-memory image when logging out (photo remains on disk & prefs).
  void clearMemory() {
    _imagePath = null;
    notifyListeners();
  }
}
