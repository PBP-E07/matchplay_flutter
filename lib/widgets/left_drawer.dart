import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/equipment/screens/equipment_list.dart';
import 'package:matchplay_flutter/main.dart'; 

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
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
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Halaman Utama'),
            onTap: () {
              // Navigasi ke Halaman Utama
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(title: 'MatchPlay'),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.sports_tennis), // Icon diganti biar sesuai
            title: const Text('Daftar Equipment'),
            onTap: () {
                // Navigasi ke Daftar Equipment
                Navigator.push(
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