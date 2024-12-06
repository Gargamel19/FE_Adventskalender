import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  String _title = 'Sample Title';
  String _description = 'This is a sample description.';
  String _imageUrl = 'https://via.placeholder.com/150';

  String get title => _title;
  String get description => _description;
  String get imageUrl => _imageUrl;

  AppState() {
    _loadFromPreferences();
  }

  void _loadFromPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    _title = preferences.getString('title') ?? 'Sample Title';
    _description = preferences.getString('description') ?? 'This is a sample description.';
    _imageUrl = preferences.getString('imageUrl') ?? 'https://via.placeholder.com/150';
    notifyListeners();
  }

  void _saveToPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('title', _title);
    preferences.setString('description', _description);
    preferences.setString('imageUrl', _imageUrl);
  }

  void updateTitle(String newTitle) {
    _title = newTitle;
    _saveToPreferences();
    notifyListeners();
  }

  void updateDescription(String newDescription) {
    _description = newDescription;
    _saveToPreferences();
    notifyListeners();
  }

  void updateImageUrl(String newImageUrl) {
    _imageUrl = newImageUrl;
    _saveToPreferences();
    notifyListeners();
  }
}
