import 'package:flutter/material.dart';
import '../features/home/screens/home_page.dart';
import '../features/blog/screens/blog_entry_list.dart';
import 'package:matchplay_flutter/features/dashboard/screens/admin_dashboard_screen.dart';
import 'package:matchplay_flutter/features/equipment/screens/equipment_list.dart';
import 'package:matchplay_flutter/features/tournament/screens/tournament_list.dart';
import 'package:matchplay_flutter/features/matches/screens/create_match_form.dart'; 

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Column(
              children: [
                Text(
                  'MatchPlay',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Cari kebutuhan olahragamu!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // 1. Halaman Utama
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Halaman Utama'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),

          // Matchmake (Fitur Teman - DIKEMBALIKAN)
          ListTile(
            leading: const Icon(Icons.create), // Ikon sesuai Navbar
            title: const Text('Matchmake'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CreateMatchForm()),
              );
            },
          ),

          // Daftar Turnamen (Fitur Baru)
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Daftar Turnamen'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TournamentListPage()),
              );
            },
          ),

          // Dashboard Admin
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Dashboard Admin'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
                ),
              );
            },
          ),

          // Equipment
          ListTile(
            leading: const Icon(Icons.sports_tennis),
            title: const Text('Daftar Equipment'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const EquipmentPage()),
              );
            },
          ),

          //Blog
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Blog'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlogEntryListPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}