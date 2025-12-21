import 'package:flutter/material.dart';
import 'package:matchplay_flutter/widgets/left_drawer.dart';

// Management Screen
import 'fields/field_management_screen.dart';
import 'equipment/equipment_management_screen.dart';
import 'blog/blog_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Jumlah Tab
      child: Scaffold(
        // 1. AppBar milik Parent (Admin Dashboard)
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,

          // 2. TabBar Navigasi
          bottom: const TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(icon: Icon(Icons.stadium), text: "Fields"),
              Tab(icon: Icon(Icons.sports_tennis), text: "Equipment"),
              Tab(icon: Icon(Icons.article), text: "Blogs"),
            ],
          ),
        ),

        // 3. Drawer Utama (Hanya ada di Parent)
        drawer: const LeftDrawer(),

        // 4. Isi Konten (Swappable)
        body: const TabBarView(
          children: [
            // Tab 1: Modul Lapangan
            FieldManagementScreen(),

            // Tab 2: Modul Equipment
            EquipmentManagementScreen(),

            // Tab 3: Modul Blog
            BlogManagementScreen(),
          ],
        ),
      ),
    );
  }
}
