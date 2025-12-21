import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:matchplay_flutter/features/equipment/models/equipment.dart';
import 'package:matchplay_flutter/widgets/custom_bottom_navbar.dart';
import 'package:matchplay_flutter/features/equipment/screens/equipment_form.dart';
import 'dart:async';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final String baseUrl = 'http://localhost:8000';
  String _searchQuery = "";
  String _selectedCategory = "All";
  
  // Variabel state untuk menyimpan status admin agar tidak tertimpa saat fetch JSON
  bool? _persistedIsAdmin; 

  final List<String> _categories = ["All", "Padel", "Golf", "Volley", "Bola", "Basket"];
  final List<String> _timeSlots = [
    "06:00-07:00", "07:00-08:00", "08:00-09:00", "09:00-10:00",
    "10:00-11:00", "11:00-12:00", "13:00-14:00", "14:00-15:00",
    "15:00-16:00", "16:00-17:00", "17:00-18:00", "18:00-19:00",
  ];

  Future<List<Equipment>> fetchEquipment(CookieRequest request) async {
    var response = await request.get('$baseUrl/equipment/json/');
    List<Equipment> listEquipment = [];
    for (var d in response) {
      if (d != null) {
        Equipment eq = Equipment.fromJson(d);
        String name = eq.fields.name.toLowerCase();
        if (name.contains(_searchQuery.toLowerCase()) &&
            (_selectedCategory == "All" || name.contains(_selectedCategory.toLowerCase()))) {
          listEquipment.add(eq);
        }
      }
    }
    return listEquipment;
  }

  Future<void> _deleteEquipment(CookieRequest request, int pk) async {
    final response = await request.post('$baseUrl/equipment/delete-flutter/$pk/', {});
    if (response['status'] == 'success') {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alat berhasil dihapus!"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Amankan status Admin: jsonData hanya berisi data login saat awal login
    if (request.jsonData is Map) {
      if (request.jsonData['is_admin'] == true || 
          request.jsonData['is_staff'] == true || 
          request.jsonData['username'] == 'admin2') {
        _persistedIsAdmin = true;
      }
    }
    final bool isAdmin = _persistedIsAdmin ?? false;

    // Index aktif sesuai CustomBottomNavBar terbaru:
    // Admin (6 menu): Equip di index 4 | User (4 menu): Equipment di index 2
    int activeIndex = isAdmin ? 4 : 2; 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MatchPlay Equipment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data.isEmpty) return const Center(child: Text("No equipment found."));

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.62,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildProductCard(snapshot.data![index], request, isAdmin),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      // --- Tombol Tambah Alat (Khusus Admin) ---
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00BFA6),
        label: const Text("Tambah Alat", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EquipmentFormPage())),
      ) : null,
      bottomNavigationBar: CustomBottomNavBar(
        isAdmin: isAdmin,
        currentIndex: activeIndex,
      ),
    );
  }

  // --- Widget Helper: Search & Filter ---
  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Search equipment...",
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.grey[100],
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_categories[i]),
                selected: _selectedCategory == _categories[i],
                onSelected: (s) => setState(() => _selectedCategory = s ? _categories[i] : "All"),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget Helper: Card Produk (Fitur Admin muncul di sini) ---
  Widget _buildProductCard(Equipment item, CookieRequest request, bool isAdmin) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(_getImageUrl(item.fields.image), fit: BoxFit.cover, width: double.infinity, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.fields.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Stock: ${item.fields.quantity} | Rp ${item.fields.pricePerHour}", style: const TextStyle(color: Color(0xFF10B981), fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- Fitur Edit & Hapus (Muncul jika isAdmin == true) ---
                    if (isAdmin) ...[
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.blue), 
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EquipmentFormPage(equipment: item)))
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red), 
                        onPressed: () => _showDeleteConfirmation(request, item)
                      ),
                    ] else ...[
                      // Fitur User Biasa (Info & Sewa)
                      GestureDetector(onTap: () => _showDetailModal(item), child: const Icon(Icons.info_outline, size: 22, color: Colors.grey)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size(60, 30), padding: EdgeInsets.zero),
                        onPressed: () => _showBookingBottomSheet(item, request),
                        child: const Text("Sewa", style: TextStyle(fontSize: 10, color: Colors.white)),
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

  // --- Fungsi Modals (Booking, Payment, Detail, Delete Confirmation) ---

  void _showBookingBottomSheet(Equipment item, CookieRequest request) {
    DateTime? selectedDate; String? selectedTime; int quantity = 1;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Sewa ${item.fields.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF10B981)),
                title: Text(selectedDate == null ? "Pilih Tanggal" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
                  if (picked != null) setModalState(() => selectedDate = picked);
                },
              ),
              const Text("Pilih Jam (1 Jam):"),
              SizedBox(
                height: 100,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    children: _timeSlots.map((time) => ChoiceChip(
                      label: Text(time, style: TextStyle(fontSize: 11, color: selectedTime == time ? Colors.white : Colors.black)),
                      selected: selectedTime == time, selectedColor: const Color(0xFF00BFA6),
                      onSelected: (s) => setModalState(() => selectedTime = s ? time : null),
                    )).toList(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Jumlah Sewa:"),
                  Row(children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: quantity > 1 ? () => setModalState(() => quantity--) : null),
                    Text("$quantity"),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: quantity < item.fields.quantity ? () => setModalState(() => quantity++) : null),
                  ]),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), minimumSize: const Size(double.infinity, 50)),
                onPressed: (selectedDate == null || selectedTime == null) ? null : () {
                  Navigator.pop(context);
                  _showPaymentModal(item, request, selectedDate!, selectedTime!, quantity);
                },
                child: const Text("Lanjut ke Pembayaran", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentModal(Equipment item, CookieRequest request, DateTime date, String slot, int qty) {
    int startSeconds = 300; Timer? countdownTimer;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setPaymentState) {
          countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
            if (startSeconds > 0) setPaymentState(() => startSeconds--);
            else { timer.cancel(); Navigator.pop(context); }
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Center(child: Text("Pembayaran QRIS")),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Segera bayar dalam ${(startSeconds ~/ 60).toString().padLeft(2, '0')}:${(startSeconds % 60).toString().padLeft(2, '0')}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)), child: Image.network("https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=MatchPlay", height: 180, errorBuilder: (c, e, s) => const Icon(Icons.broken_image))),
                const SizedBox(height: 15),
                Text("Total: Rp ${double.parse(item.fields.pricePerHour) * qty}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
            actions: [
              SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                onPressed: () async {
                  countdownTimer?.cancel(); Navigator.pop(context);
                  final response = await request.post('$baseUrl/equipment/book/', {
                    'eq_id': item.pk.toString(),
                    'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                    'slot': slot, 'quantity': qty.toString(),
                  });
                  if (context.mounted) {
                    if (response['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Berhasil!")));
                      setState(() {});
                    } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response['message']}"))); }
                  }
                },
                child: const Text("Konfirmasi Telah Bayar", style: TextStyle(color: Colors.white)),
              )),
            ],
          );
        },
      ),
    ).then((_) => countdownTimer?.cancel());
  }

  // --- Utilities ---
  String _getImageUrl(String? p) => (p == null || p.isEmpty) ? "https://via.placeholder.com/150" : (p.startsWith('http') ? p : "$baseUrl/media/$p");

  void _showDeleteConfirmation(CookieRequest r, Equipment i) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Hapus Alat?"), content: Text("Yakin mau hapus ${i.fields.name}?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal")),
        TextButton(onPressed: () { Navigator.pop(c); _deleteEquipment(r, i.pk); }, child: const Text("Hapus", style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _showDetailModal(Equipment i) {
    showDialog(context: context, builder: (c) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(_getImageUrl(i.fields.image), height: 180, width: double.infinity, fit: BoxFit.cover)),
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(i.fields.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Rp ${i.fields.pricePerHour}", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          const SizedBox(height: 12), Text(i.fields.description), const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA6)), onPressed: () => Navigator.pop(c), child: const Text("Tutup", style: TextStyle(color: Colors.white)))),
        ])),
      ]),
    ));
  }
}