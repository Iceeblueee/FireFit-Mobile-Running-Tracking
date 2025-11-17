// models/navigation_model.dart
import 'package:flutter/foundation.dart';

class NavigationModel extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  // ✅ Tambahkan validasi untuk membatasi index
  void setIndex(int index) {
    if (index >= 0 && index < 4) {
      // Hanya 4 halaman: 0, 1, 2, 3
      _selectedIndex = index;
      notifyListeners();
    } else {
      print('NavigationModel: Invalid index $index. Valid range: 0-3');
    }
  }
}
