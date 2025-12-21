import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/home/screens/home_page.dart';
import 'package:matchplay_flutter/features/equipment/screens/equipment_list.dart';
import 'package:matchplay_flutter/features/blog/screens/blog_entry_list.dart';
import 'package:matchplay_flutter/features/matches/screens/create_match_form.dart';
import 'package:matchplay_flutter/features/tournament/screens/tournament_list.dart'; 
import 'package:matchplay_flutter/features/dashboard/screens/admin_dashboard_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isAdmin;
  final bool isAdmin;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [];
    if (isAdmin) {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.create), label: 'Match'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Tourney'), 
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Equip'),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Blog'),
      ];
    } else {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Tournament'), 
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Equipment'),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Blog'),
      ];
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: const Color(0xFF00BFA6),
      unselectedItemColor: Colors.black54,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed, // Ensures labels are always visible
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Equipment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: 'Blog',
        ),
      ],
    );
  }
}
