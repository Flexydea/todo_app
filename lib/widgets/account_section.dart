// lib/widgets/account_section.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import 'package:todo_app/models/user_model.dart';
import 'package:todo_app/providers/profile_photo_provider.dart';

class AccountSection extends StatefulWidget {
  const AccountSection({super.key});

  @override
  State<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection> {
  late final TextEditingController _nameController;
  bool _isEditingName = false;

  /// Quick handles to our boxes (already opened in main.dart)
  Box get _settings => Hive.box('settingsBox');
  Box<User> get _userBox => Hive.box<User>('userBox');

  /// Currently logged-in user's Hive key (int), or null if nobody is logged in
  int? get _currentUserKey => _settings.get('currentUser') as int?;

  /// Convenience getter: the active user object from Hive (nullable)
  User? get _activeUser =>
      _currentUserKey != null ? _userBox.get(_currentUserKey) : null;

  @override
  void initState() {
    super.initState();

    // Initialize the name field:
    // If we have an active user and the name is not empty, use it; otherwise fallback.
    final initialName = (() {
      final name = _activeUser?.name ?? '';
      return name.trim().isNotEmpty ? name : 'John Doe';
    })();

    _nameController = TextEditingController(text: initialName);

    // Ask the ProfilePhotoProvider to load the photo for THIS user.
    // This expects the provider to look up the per-user path (e.g. from SharedPreferences).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfilePhotoProvider>().loadForCurrentUser();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If the logged-in user changes (logout/login), refresh the name text field.
    final name = _activeUser?.name ?? '';
    if (name.trim().isNotEmpty) {
      _nameController.value = _nameController.value.copyWith(
        text: name,
        selection: TextSelection.collapsed(offset: name.length),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Toggle edit mode for the name.
  /// When leaving edit mode, persist the new name to the active user's Hive record.
  Future<void> _toggleEditName() async {
    if (_isEditingName) {
      // We are about to LEAVE edit mode → save changes
      final newNameRaw = _nameController.text.trim();
      final newName = newNameRaw.isEmpty ? 'John Doe' : newNameRaw;

      if (_currentUserKey != null) {
        final u = _userBox.get(_currentUserKey!);
        if (u != null) {
          u.name = newName; // mutate HiveObject
          await u.save(); // persist to disk
        }
      }

      // Keep UI non-empty even if user cleared the field
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = 'John Doe';
      }
    }

    setState(() => _isEditingName = !_isEditingName);
  }

  /// Open image picker via ProfilePhotoProvider and save avatar for THIS user
  Future<void> _pickImage() async {
    final photo = context.read<ProfilePhotoProvider>();

    // If no logged-in user, block avatar change for safety
    if (_currentUserKey == null) {
      _showSnack('Please sign in to set a profile photo.');
      return;
    }

    try {
      await photo
          .pickAndSave(); // provider handles copy + persist + notifyListeners
    } catch (e) {
      _showSnack('Could not save profile photo');
    }
  }

  void _showSnack(String msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Watch provider so avatar updates reactively when user picks/clears photo
    final photo = context.watch<ProfilePhotoProvider>();
    final hasImage = photo.hasImage;
    final imagePath = photo.imagePath;

    // Read-only email from active user; fallback if not logged in
    final email = _activeUser?.email ?? 'john.doe@email.com';

    return Column(
      children: [
        // Profile picture
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            backgroundImage: hasImage && imagePath != null
                ? FileImage(File(imagePath))
                : null,
            child: (!hasImage || imagePath == null)
                ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                : null,
          ),
        ),

        const SizedBox(height: 12),

        // Name + edit toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isEditingName
                ? SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _nameController,
                      style: textTheme.titleMedium,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(),
                        hintText: "Enter name",
                      ),
                    ),
                  )
                : Text(
                    _nameController.text,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            IconButton(
              icon: Icon(
                _isEditingName ? Icons.check : Icons.edit,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: _toggleEditName,
              tooltip: _isEditingName ? 'Save name' : 'Edit name',
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Read-only email
        Text(
          email,
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 16),
        const Divider(thickness: 6),
      ],
    );
  }
}
