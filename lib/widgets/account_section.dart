import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountSection extends StatefulWidget {
  const AccountSection({super.key});

  @override
  State<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection> {
  File? _profileImage;

  final TextEditingController _nameController = TextEditingController(
    text: "John Doe",
  );

  final String _email = "john.doe@email.com"; // Fixed email
  bool _isEditingName = false;

  // Image picker for profile picture
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
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
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : null,
            child: _profileImage == null
                ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                : null,
          ),
        ),
        const SizedBox(height: 12),

        // Name with edit icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isEditingName
                ? SizedBox(
                    width: 200,
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
              onPressed: () {
                setState(() {
                  _isEditingName = !_isEditingName;
                });
              },
              tooltip: _isEditingName ? 'Save name' : 'Edit name',
            ),
          ],
        ),
        // Static email display
        const SizedBox(height: 6),
        Text(_email, style: textTheme.bodySmall),
        const SizedBox(height: 16),
        const Divider(thickness: 6),
      ],
    );
  }
}
