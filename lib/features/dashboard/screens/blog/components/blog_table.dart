import 'package:flutter/material.dart';
import '../../../../blog/models/blog_entry.dart';
import '../../../widgets/admin_action_button.dart';

class BlogTable extends StatelessWidget {
  final List<Blog> blogs;
  final Function(Blog) onEdit;
  final Function(Blog) onDelete;

  const BlogTable({
    super.key,
    required this.blogs,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                    DataColumn(label: Text("TITLE", style: headerStyle)),
                    DataColumn(label: Text("AUTHOR", style: headerStyle)),
                    DataColumn(label: Text("CATEGORY", style: headerStyle)),
                    DataColumn(label: Text("VIEWS", style: headerStyle)),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("ACTION", style: headerStyle),
                        ),
                      ),
                    ),
                  ],
                  rows: blogs.map((item) {
                    return DataRow(
                      cells: [
                        // Title
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // Author
                        DataCell(Text(item.author)),

                        // Category (Chip Style)
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                        // Views
                        DataCell(Text(item.blogViews.toString())),

                        // Actions
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
                                const SizedBox(width: 8),
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
