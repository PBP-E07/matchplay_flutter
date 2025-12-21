import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/screens/blog_entry_list.dart';
import 'package:matchplay_flutter/features/blog/screens/menu.dart';
import 'package:matchplay_flutter/features/dashboard/screens/admin_dashboard_screen.dart';
import 'package:matchplay_flutter/features/equipment/screens/equipment_list.dart';

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

          // Halaman Utama
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Halaman Utama'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BlogEntryListPage()),
              );
            },
          ),

          // Dashboard
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

          // Daftar Equipment
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
        ],
      ),
    );
  }
}
