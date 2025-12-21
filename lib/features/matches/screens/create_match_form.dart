import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreateMatchForm extends StatefulWidget {
  const CreateMatchForm({super.key});

  @override
  State<CreateMatchForm> createState() => _CreateMatchFormState();
}

class _CreateMatchFormState extends State<CreateMatchForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedTimeSlot;
  int? _selectedFieldId;
  DateTime _selectedDate = DateTime.now();
  
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _maxPlayersController = TextEditingController(text: "10");

  List<String> _occupiedSlots = [];
  List<dynamic> _fields = [];

  final List<String> timeSlots = [
    '10.00-11.00',
    '11.00-12.00',
    '12.00-13.00',
    '13.00-14.00',
  ];

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchFields();
    });
  }

  Future<void> fetchFields() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://localhost:8000/api/fields/?per_page=10000');
    
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      if (response['data'] is Map && response['data']['fields'] is List) {
         setState(() {
           _fields = response['data']['fields'];
         });
      } 

      else if (response['data'] is List) {
        setState(() {
          _fields = response['data'];
        });
      }
    } else if (response is List) {
      setState(() {
        _fields = response;
      });
    }
  }

  Future<List<String>> fetchOccupiedSlots(int fieldId, DateTime date) async {
    final request = context.read<CookieRequest>();
    final dateStr = date.toIso8601String().split('T')[0];

    final response = await request.get(
      'http://localhost:8000/api/matches/slots/?field_id=$fieldId&date=$dateStr',
    );

    if (response['status'] == 'success') {
      List<dynamic> rawSlots = response['occupied_slots'];
      return rawSlots.map((slot) => slot.toString()).toList();
    } else {
      return [];
    }
  }

  void _updateSlots() async {
    if (_selectedFieldId != null) {
      List<String> taken = await fetchOccupiedSlots(
        _selectedFieldId!,
        _selectedDate,
      );
      setState(() {
        _occupiedSlots = taken;
        if (_occupiedSlots.contains(_selectedTimeSlot)) {
          _selectedTimeSlot = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text("Create New Match")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Select Field"),
                  value: _selectedFieldId,
                  items: _fields.map<DropdownMenuItem<int>>((dynamic field) {
                    return DropdownMenuItem<int>(
                      value: field['id'],
                      child: Text(field['name']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedFieldId = val;
                    });
                    _updateSlots();
                  },
                  validator: (val) => val == null ? "Please select a field" : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Time Slot"),
                  value: _selectedTimeSlot,
                  items: timeSlots.map((String slot) {
                    bool isTaken = _occupiedSlots.contains(slot);
                    return DropdownMenuItem(
                      value: slot,
                      enabled: !isTaken,
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: isTaken ? Colors.grey : Colors.black,
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedTimeSlot = val),
                  validator: (val) => val == null ? "Please select a slot" : null,
                ),
                const SizedBox(height: 16),
            
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: "Price per person",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter price";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _maxPlayersController,
                  decoration: const InputDecoration(
                    labelText: "Maximum Players",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter max players";
                    return null;
                  },
                ),
                const SizedBox(height: 24),
            
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        _selectedFieldId != null) {
                      final response = await request
                          .post("http://localhost:8000/api/matches/", {
                            "field_id": _selectedFieldId.toString(),
                            "time_slot": _selectedTimeSlot,
                            "date": _selectedDate.toIso8601String().split('T')[0],
                            "price": _priceController.text,
                            "max_players": _maxPlayersController.text, // Added this
                          });
            
                      if (response['status'] == 'success') {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Match Created!")),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['message'] ?? "Error"),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("Create Match"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
