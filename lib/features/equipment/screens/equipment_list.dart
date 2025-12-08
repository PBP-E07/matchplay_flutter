import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:matchplay_flutter/features/equipment/models/equipment.dart';
import 'package:matchplay_flutter/widgets/left_drawer.dart';
import 'package:matchplay_flutter/features/equipment/screens/equipment_form.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  // Fungsi Fetch Data dari Django
  Future<List<Equipment>> fetchEquipment(CookieRequest request) async {
    // ⚠️ Ganti URL ini sesuai device lu:
    // - Chrome/Web: 'http://127.0.0.1:8000/equipment/json/'
    // - Android Emulator: 'http://10.0.2.2:8000/equipment/json/'
    // - HP Fisik: Pake IP Laptop (misal 'http://192.168.1.5:8000/equipment/json/')
    var response = await request.get('http://127.0.0.1:8000/equipment/json/');

    // Parsing JSON ke List<Equipment>
    List<Equipment> listEquipment = [];
    for (var d in response) {
      if (d != null) {
        listEquipment.add(Equipment.fromJson(d));
      }
    }
    return listEquipment;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Equipment'),
        backgroundColor: Colors.blueAccent, // Sesuaikan tema
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(), // Pastiin lu udah punya LeftDrawer
      body: FutureBuilder(
        future: fetchEquipment(request),
        builder: (context, AsyncSnapshot snapshot) {
          // 1. Handle Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Handle Error (PENTING BIAR TAU KENAPA)
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // 3. Handle Data Kosong
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada equipment.",
                style: TextStyle(color: Color(0xff59A5D8), fontSize: 20),
              ),
            );
          }
          // 4. Handle Data Ada
          else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];

                // Logic Gambar: Cek dulu null atau nggak
                String? imageUrl;
                if (item.fields.image != null &&
                    item.fields.image!.isNotEmpty) {
                  imageUrl = 'http://127.0.0.1:8000/media/${item.fields.image}';
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tampilkan Gambar cuma kalau URL-nya ada
                        if (imageUrl != null)
                          Image.network(
                            imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                          )
                        else
                          // Placeholder kalau gak ada gambar
                          Container(
                            height: 100,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.sports_tennis,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),

                        const SizedBox(height: 10),
                        Text(
                          item.fields.name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text("Jumlah: ${item.fields.quantity}"),
                        Text("Harga: Rp ${item.fields.pricePerHour}"),
                        const SizedBox(height: 10),
                        Text(item.fields.description),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      // Tombol Tambah (Floating Action Button)
      floatingActionButton: FloatingActionButton.extended(
        // Bikin tombol jadi lonjong ada tulisannya (Lebih Keren & Modern)
        label: const Text(
          'Tambah Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent, // Sesuaikan warna tema
        // Logic Navigasi (Biar bisa dipencet)
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EquipmentFormPage()),
          );
        },
      ),
    );
  }
}
