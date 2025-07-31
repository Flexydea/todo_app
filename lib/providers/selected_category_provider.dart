import 'package:flutter/material.dart';

class SelectedCategoryProvider extends ChangeNotifier {
  String? _selectedCategory;

  String? get selectedCategory => _selectedCategory;

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearCategory() {
    _selectedCategory = null;
    notifyListeners();
  }
}
