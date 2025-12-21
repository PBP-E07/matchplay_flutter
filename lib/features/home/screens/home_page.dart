import 'package:flutter/material.dart';
import 'package:matchplay_flutter/features/blog/screens/blog_entry_list.dart';
import 'package:matchplay_flutter/features/fields/models/field.dart';
import 'package:matchplay_flutter/features/home/widgets/field_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:matchplay_flutter/features/equipment/screens/equipment_list.dart';
import 'package:matchplay_flutter/features/dashboard/screens/admin_dashboard_screen.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;

  const HomePage({super.key, this.isAdmin = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Field>> fetchFields(CookieRequest request) async {
    final response = await request.get(
      'http://localhost:8000/api/fields/?per_page=10000',
    );

    var dataList = [];

    if (response is Map<String, dynamic>) {
      if (response.containsKey('data') && response['data'] is Map) {
        dataList = response['data']['fields'];
      }
    }

    List<Field> listFields = [];

    for (var d in dataList) {
      if (d != null) {
        listFields.add(Field.fromJson(d));
      }
    }

    return listFields;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(color: Color(0xFF00BFA6)),
          ),

          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "Matchplay",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Find your venues with a search",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Search Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: "Search matches, venues...",
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Search Now"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: FutureBuilder(
                    future: fetchFields(request),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                        return const Center(
                          child: Text('No fields available.'),
                        );
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 0, bottom: 20),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (_, index) =>
                              FieldCard(field: snapshot.data![index]),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        height: 70,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, "Home", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(isAdmin: widget.isAdmin),
                ),
              );
            }),

            if (widget.isAdmin)
              _buildBottomNavItem(Icons.dashboard, "Admin", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              }),

            _buildBottomNavItem(Icons.shopping_cart, "Equip", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EquipmentPage()),
              );
            }),

            _buildBottomNavItem(Icons.article, "Blog", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlogEntryListPage(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 28, color: Colors.black87)],
      ),
    );
  }
}
