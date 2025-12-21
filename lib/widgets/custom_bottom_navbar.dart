import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isAdmin;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => onTap(index),
      selectedItemColor: const Color(0xFF00BFA6),
      unselectedItemColor: Colors.black54,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      // HILANGKAN LABEL AGAR HANYA IKON (SESUAI REQUEST)
      showSelectedLabels: false, 
      showUnselectedLabels: false,
      items: isAdmin ? _adminItems : _userItems,
    );
  }

  List<BottomNavigationBarItem> get _adminItems => const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Add'),
    BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'List'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Booking'),
    BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Blog'),
  ];

  List<BottomNavigationBarItem> get _userItems => const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Equipment'),
    BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Blog'),
  ];
}