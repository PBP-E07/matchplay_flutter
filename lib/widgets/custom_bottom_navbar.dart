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

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.isAdmin = false,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    if (isAdmin) {
      switch (index) {
        case 0:
          page = const HomePage();
          break;
        case 1:
          page = const CreateMatchForm();
          break;
        case 2:
          page = const TournamentListPage();
          break;
        case 3:
          page = const AdminDashboardScreen();
          break;
        case 4:
          page = const EquipmentPage();
          break;
        case 5:
          page = const BlogEntryListPage();
          break;
        default:
          return;
      }
    } else {
      switch (index) {
        case 0:
          page = const HomePage();
          break;
        case 1:
          page = const TournamentListPage();
          break;
        case 2:
          page = const EquipmentPage();
          break;
        case 3:
          page = const BlogEntryListPage();
          break;
        default:
          return;
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [];
    if (isAdmin) {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.create), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: ''),
      ];
    } else {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: ''),
      ];
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      selectedItemColor: const Color(0xFF00BFA6),
      unselectedItemColor: Colors.black87,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: items,
      // INI KUNCINYA UNTUK MENGHILANGKAN TULISAN
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }
}
