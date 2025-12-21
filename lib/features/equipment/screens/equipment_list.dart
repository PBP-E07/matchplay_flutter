import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:matchplay_flutter/features/equipment/models/equipment.dart';
import 'package:matchplay_flutter/widgets/custom_bottom_navbar.dart';
import 'package:matchplay_flutter/config.dart';
import 'package:matchplay_flutter/features/equipment/screens/equipment_form.dart';
import 'dart:async';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final String baseUrl = AppConfig.baseUrl;
  String _searchQuery = "";
  String _selectedCategory = "All";

  // Slot jam per 1 jam sesuai request
  final List<String> _timeSlots = [
    "06:00-07:00",
    "07:00-08:00",
    "08:00-09:00",
    "09:00-10:00",
    "10:00-11:00",
    "11:00-12:00",
    "13:00-14:00",
    "14:00-15:00",
    "15:00-16:00",
    "16:00-17:00",
    "17:00-18:00",
    "18:00-19:00",
    "19:00-20:00",
    "20:00-21:00",
    "21:00-22:00",
  ];

  Future<List<Equipment>> fetchEquipment(CookieRequest request) async {
    var response = await request.get('$baseUrl/equipment/json/');
    List<Equipment> listEquipment = [];
    for (var d in response) {
      if (d != null) {
        Equipment eq = Equipment.fromJson(d);
        String name = eq.fields.name.toLowerCase();
        if (name.contains(_searchQuery.toLowerCase())) {
          if (_selectedCategory == "All" ||
              name.contains(_selectedCategory.toLowerCase())) {
            listEquipment.add(eq);
          }
        }
      }
    }
    return listEquipment;
  }

  Future<void> _deleteEquipment(CookieRequest request, int id) async {
    try {
      final response = await request.post(
        '$baseUrl/equipment/delete-flutter/$id/',
        {},
      );
      if (response['status'] == 'success') {
        setState(() {}); // Refresh halaman
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal menghapus")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isAdmin = request.jsonData['is_staff'] ?? false;
    final int navIndex = isAdmin ? 4 : 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MatchPlay Equipment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchAndFilter(),
            FutureBuilder(
              future: fetchEquipment(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data.isEmpty)
                  return const Center(child: Text("No equipment found."));

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildProductCard(
                    snapshot.data![index],
                    request,
                    isAdmin,
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF00BFA6),
              label: const Text(
                "Tambah Alat",
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EquipmentFormPage(),
                  ),
                );
                setState(() {}); // Refresh setelah kembali dari form
              },
            )
          : null,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: navIndex,
        isAdmin: isAdmin,
      ),
    );
  }

  // --- MODAL SEWA ---
  void _showBookingBottomSheet(Equipment item, CookieRequest request) {
    DateTime? selectedDate;
    String? selectedTime;
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  const SizedBox(height: 15),
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
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null)
                        setModalState(() => selectedDate = picked);
                    },
                  ),
                  const Text(
                    "Pilih Jam (1 Jam):",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        children: _timeSlots.map((time) {
                          bool isSelected = selectedTime == time;
                          return ChoiceChip(
                            label: Text(
                              time,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFF00BFA6),
                            onSelected: (selected) => setModalState(
                              () => selectedTime = selected ? time : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Jumlah Sewa:"),
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: (selectedDate == null || selectedTime == null)
                        ? null
                        : () {
                            Navigator.pop(context);
                            _showPaymentModal(
                              item,
                              request,
                              selectedDate!,
                              selectedTime!,
                              quantity,
                            );
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

  // --- MODAL PEMBAYARAN QRIS (FIX) ---
  void _showPaymentModal(
    Equipment item,
    CookieRequest request,
    DateTime date,
    String slot,
    int qty,
  ) {
    int startSeconds = 300; // 5 Menit timer
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPaymentState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (
              timer,
            ) {
              if (startSeconds > 0) {
                setPaymentState(() => startSeconds--);
              } else {
                timer.cancel();
                Navigator.pop(context);
              }
            });

            String minutes = (startSeconds ~/ 60).toString().padLeft(2, '0');
            String seconds = (startSeconds % 60).toString().padLeft(2, '0');

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Center(
                child: Text(
                  "Pembayaran QRIS",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Segera bayar dalam $minutes:$seconds",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // PNG GENERATOR AGAR GAMBAR MUNCUL
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Image.network(
                      "https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=MatchPlayPayment",
                      height: 180,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Total: Rp ${double.parse(item.fields.pricePerHour) * qty}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              actions: [
                // Di dalam AlertDialog -> actions
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                    onPressed: () async {
                      countdownTimer?.cancel();

                      // 1. LANGSUNG TUTUP POP-UP (Sesuai request lo, Boy)
                      Navigator.pop(context);

                      try {
                        // 2. JALANKAN PROSES BOOKING DI BACKGROUND
                        final response = await request
                            .post('$baseUrl/equipment/book/', {
                              'eq_id': item.pk.toString(),
                              'date': "${date.year}-${date.month}-${date.day}",
                              'slot': slot,
                              'quantity': qty.toString(),
                            });

                        if (response['status'] == 'success') {
                          // 3. MUNCULIN NOTIFIKASI BERHASIL
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Booking Berhasil!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          setState(() {}); // Refresh list biar stok berkurang
                        } else {
                          // Notif kalau gagal (misal stok habis di detik terakhir)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal: ${response['message']}"),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Terjadi kesalahan koneksi!"),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Konfirmasi Telah Bayar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => countdownTimer?.cancel());
  }

  // --- WIDGET LAINNYA ---
  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Search...",
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
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: [
              "All",
              "Padel",
              "Golf",
              "Volley",
              "Bola",
              "Basket",
            ].length,
            itemBuilder: (context, i) {
              String cat = [
                "All",
                "Padel",
                "Golf",
                "Volley",
                "Bola",
                "Basket",
              ][i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (s) =>
                      setState(() => _selectedCategory = s ? cat : "All"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    Equipment item,
    CookieRequest request,
    bool isAdmin,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
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
                _getImageUrl(item.fields.image),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Stock: ${item.fields.quantity} | Rp ${item.fields.pricePerHour}",
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isAdmin) ...[
                      // Tombol Edit
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.blue,
                        ),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(), // Agar tidak makan tempat
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EquipmentFormPage(),
                            ),
                          );
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      // Tombol Delete
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          // Konfirmasi Hapus
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Hapus Alat"),
                              content: Text(
                                "Yakin ingin menghapus ${item.fields.name}?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Batal"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _deleteEquipment(request, item.pk);
                                  },
                                  child: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      const Icon(
                        Icons.info_outline,
                        size: 22,
                        color: Colors.grey,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          minimumSize: const Size(60, 30),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => _showBookingBottomSheet(item, request),
                        child: const Text(
                          "Sewa",
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getImageUrl(String? p) => (p == null || p.isEmpty)
      ? "https://via.placeholder.com/150"
      : (p.startsWith('http') ? p : "$baseUrl/media/$p");
}
