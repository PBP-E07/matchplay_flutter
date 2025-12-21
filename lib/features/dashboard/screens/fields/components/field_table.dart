// Package Umum
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Fields
import '../../../../fields/models/field.dart';

// Shared Widgets
import '../../../widgets/admin_action_button.dart';

class FieldTable extends StatelessWidget {
  final List<Field> fields;
  final Function(Field) onEdit;
  final Function(Field) onDelete;

  const FieldTable({
    super.key,
    required this.fields,
    required this.onEdit,
    required this.onDelete,
  });

  String _getSportLabel(String value) {
    const Map<String, String> labels = {
      'badminton': 'Badminton',
      'basketball': 'Basketball',
      'billiard': 'Billiard',
      'e-sport': 'E-Sport',
      'futsal': 'Futsal',
      'golf': 'Golf',
      'mini soccer': 'Mini Soccer',
      'padel': 'Padel',
      'pickleball': 'Pickleball',
      'sepak bola': 'Sepak Bola',
      'squash': 'Squash',
      'tenis meja': 'Tenis Meja',
      'tennis': 'Tennis',
    };
    return labels[value] ?? value;
  }

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
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 64,
                  headingRowHeight: 56,
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                  columnSpacing: 24,
                  columns: [
                    DataColumn(label: Text("NAME", style: headerStyle)),
                    DataColumn(label: Text("SPORT", style: headerStyle)),
                    DataColumn(label: Text("LOCATION", style: headerStyle)),
                    DataColumn(label: Text("PRICE", style: headerStyle)),
                    DataColumn(label: Text("RATING", style: headerStyle)),

                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("ACTION", style: headerStyle),
                        ),
                      ),
                    ),
                  ],
                  rows: fields.map((field) {
                    return DataRow(
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              field.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        DataCell(Text(_getSportLabel(field.sport))),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              field.location,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(currencyFormat.format(field.price))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                field.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AdminActionButton(
                                  icon: Icons.edit,
                                  color: Colors.amber,
                                  onTap: () => onEdit(field),
                                ),
                                const SizedBox(width: 8),
                                AdminActionButton(
                                  icon: Icons.delete,
                                  color: Colors.redAccent,
                                  onTap: () => onDelete(field),
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
