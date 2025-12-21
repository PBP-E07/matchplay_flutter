import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:matchplay_flutter/features/equipment/models/equipment.dart';
import 'package:matchplay_flutter/widgets/left_drawer.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  // Gunakan 127.0.0.1 untuk Chrome, atau 10.0.2.2 untuk Android Emulator
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<List<Equipment>> fetchEquipment(CookieRequest request) async {
    var response = await request.get('$baseUrl/equipment/json/');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MatchPlay Equipment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search equipment...",
                  prefixIcon: const Icon(Icons.search),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 2. Filter Kategori (Padel, Golf, Volley)
            _buildCategorySection(),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                "Newest Arrival",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 3. Grid View for Equipment
            FutureBuilder(
              future: fetchEquipment(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return const Center(child: Text("Belum ada equipment."));
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.68, // Agar card proporsional
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return _buildProductCard(item, request);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildCategorySection() {
    List<String> categories = ["Padel", "Golf", "Volley"];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isFirst = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                categories[index],
                style: TextStyle(color: isFirst ? Colors.white : Colors.black),
              ),
              backgroundColor: isFirst
                  ? const Color(0xFF86EFAC)
                  : Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Equipment item, CookieRequest request) {
    // FIX GAMBAR: Logic biar Unsplash & Lokal muncul semua
    String imageUrl = item.fields.image ?? "";
    if (imageUrl.startsWith('http')) {
      imageUrl = imageUrl;
    } else if (imageUrl.isNotEmpty) {
      imageUrl = "$baseUrl/media/$imageUrl";
    } else {
      imageUrl = "https://via.placeholder.com/150";
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fields.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "Rp ${item.fields.pricePerHour}",
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Detail (Ikon Info)
                    GestureDetector(
                      onTap: () => _showDetailModal(item),
                      child: const Icon(
                        Icons.info_outline,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),
                    // Tombol Sewa
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        minimumSize: const Size(65, 30),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _showBookingBottomSheet(item, request),
                      child: const Text(
                        "Sewa",
                        style: TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL & LOGIC SEWA ---

  void _showDetailModal(Equipment item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.fields.name),
        content: Text(item.fields.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showBookingBottomSheet(Equipment item, CookieRequest request) {
    DateTime? selectedDate;
    int quantity = 1; // Default jumlah sewa

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Pake StatefulBuilder biar UI di dalam modal bisa berubah pas ganti tanggal/jumlah
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sewa ${item.fields.name}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 1. PILIH TANGGAL ---
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF10B981),
                    ),
                    title: Text(
                      selectedDate == null
                          ? "Pilih Tanggal"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setModalState(
                          () => selectedDate = picked,
                        ); // Update modal UI
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  // --- 2. JUMLAH SEWA ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Jumlah Sewa:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: quantity > 1
                                ? () => setModalState(() => quantity--)
                                : null,
                          ),
                          Text(
                            "$quantity",
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: quantity < item.fields.quantity
                                ? () => setModalState(() => quantity++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- 3. TOMBOL LANJUT ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: selectedDate == null
                        ? null
                        : () {
                            // Kirim data ke Django lo (/equipment/book/)
                            // print(
                            //   "Booking: ${item.fields.name}, Qty: $quantity, Date: $selectedDate",
                            // );
                            Navigator.pop(context);
                          },
                    child: const Text(
                      "Lanjut ke Pembayaran",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
