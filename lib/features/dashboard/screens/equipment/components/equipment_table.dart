// Package Umum
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Equipment
import '../../../../equipment/models/equipment.dart';

// Shared Widgets
import '../../../widgets/admin_action_button.dart';

class EquipmentTable extends StatelessWidget {
  final List<Equipment> equipments;
  final Function(Equipment) onEdit;
  final Function(Equipment) onDelete;

  const EquipmentTable({
    super.key,
    required this.equipments,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey[800],
      fontSize: 14,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.grey[200]),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columnSpacing: 24,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 64,
                  headingRowHeight: 56,
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                  columns: [
                    DataColumn(label: Text("NAME", style: headerStyle)),
                    DataColumn(label: Text("QUANTITY", style: headerStyle)),
                    DataColumn(label: Text("PRICE / HOUR", style: headerStyle)),
                    // Header Action di tengah
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("ACTION", style: headerStyle),
                        ),
                      ),
                    ),
                  ],
                  rows: equipments.map((item) {
                    return DataRow(
                      cells: [
                        // Nama
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              item.fields.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // Quantity
                        DataCell(Text(item.fields.stock.toString())),
                        // Price
                        DataCell(
                          Text(
                            currencyFormat.format(
                              double.parse(item.fields.price),
                            ),
                          ),
                        ),
                        // Action Buttons
                        DataCell(
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AdminActionButton(
                                  icon: Icons.edit,
                                  color: Colors.amber,
                                  onTap: () => onEdit(item),
                                ),
                                const SizedBox(width: 8), // Jarak antar tombol
                                AdminActionButton(
                                  icon: Icons.delete,
                                  color: Colors.redAccent,
                                  onTap: () => onDelete(item),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
