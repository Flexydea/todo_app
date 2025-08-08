import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class AccountSection extends StatefulWidget {
  const AccountSection({super.key});

  @override
  State<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection> {
  Uint8List? _profileImageBytes;
  late final TextEditingController _nameController;
  bool _isEditingName = false;

  // Non-editable email (load from Hive if present, otherwise default)
  late final String _email;

  Box get _settings => Hive.box('settingsBox');

  @override
  void initState() {
    super.initState();

    // Load saved name
    final savedName = (_settings.get('displayName') as String?) ?? 'John Doe';
    _nameController = TextEditingController(text: savedName);

    // Load saved image BYTES
    final bytes = _settings.get('profileImageBytes');
    if (bytes != null && bytes is Uint8List) {
      _profileImageBytes = bytes;
    }

    // (Optional) clean old path key if you used it before
    if (_settings.containsKey('profileImagePath')) {
      _settings.delete('profileImagePath');
    }

    // Load email (read-only display)
    _email = (_settings.get('email') as String?) ?? 'john.doe@email.com';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final bytes = await picked.readAsBytes();
      await _settings.put('profileImageBytes', bytes);
      setState(() => _profileImageBytes = bytes);
    } catch (e) {
      debugPrint('Failed to save avatar bytes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save profile photo')),
        );
      }
    }
  }

  Future<void> _toggleEditName() async {
    if (_isEditingName) {
      final name = _nameController.text.trim();
      await _settings.put('displayName', name.isEmpty ? 'John Doe' : name);
      if (name.isEmpty) _nameController.text = 'John Doe';
    }
    setState(() => _isEditingName = !_isEditingName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      children: [
        // Profile picture
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            backgroundImage: _profileImageBytes != null
                ? MemoryImage(_profileImageBytes!)
                : null,
            child: _profileImageBytes == null
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(),
                        hintText: "Enter name",
                      ),
                    ),
                  )
                : Text(_nameController.text, style: textTheme.titleMedium),
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
          _email,
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
