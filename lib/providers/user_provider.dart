import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;

  void setAdmin(bool value) {
    _isAdmin = value;
    notifyListeners(); // Memberitahu semua halaman bahwa status berubah
  }
}
