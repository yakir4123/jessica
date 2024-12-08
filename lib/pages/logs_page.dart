import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/models/audit_logs.dart';
import 'package:jessica/models/minutly_updates.dart';
import 'package:jessica/services/logs_table_provider.dart';
import 'package:jessica/services/providers.dart';

class LogsTablePage extends ConsumerWidget {
  const LogsTablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataServiceProvider);
    if (data == null) {
      return const Center(
        child: Text('No orders available'),
      );
    }
    final selectedSymbol = ref.watch(selectedSymbolProvider);

    return Scaffold(
      appBar: createAppBar(context, ref, selectedSymbol, data.routesParams),
      body: createBody(context, ref, selectedSymbol),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFormDialog(context, ref);
        },
        child: Transform.rotate(
          angle: 90 * (3.141592653589793 / 180),
          // Convert 90 degrees to radians
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  AppBar createAppBar(BuildContext context, WidgetRef ref,
      String? selectedSymbol, List<RouteWithOrdersModel> routes) {
    return AppBar(
      title: DropdownButtonHideUnderline(
        // Hide the underline to match app bar style
        child: DropdownButton<String>(
          hint: Text(
            selectedSymbol ?? 'Select a symbol',
            style: const TextStyle(
                color: Colors.white), // Set text color to match app bar
          ),
          value: selectedSymbol,
          dropdownColor: Theme.of(context).primaryColor,
          // Match app bar background color
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          // Set icon color
          onChanged: (String? newSymbol) {
            ref.read(selectedStrategyProvider.notifier).state = null;
            ref.read(selectedSymbolProvider.notifier).state = newSymbol;
          },
          items: routes.map((RouteWithOrdersModel route) {
            return DropdownMenuItem<String>(
              value: route.symbol,
              child: Text(route.symbol),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget createToolBar(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logsProvider); // Access the logs list here
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Button next to the list
        ElevatedButton(
          onPressed: () {
            final queries = ref.watch(logsProvider);
            ref.read(auditLogsNotifierProvider.notifier).requestLogs(queries);
          },
          child: const Icon(Icons.search),
        ),
        // List of cards
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                logs.length, // Use the length of the logs list
                (index) => GestureDetector(
                  onDoubleTap: () {
                    // Call the dialog and pass the current log entry's data
                    _showFormDialog(context, ref,
                        columnSetting: logs[index], index: index);
                  },
                  onLongPress: () {
                    // Remove the item at the given index
                    ref.read(logsProvider.notifier).removeQuery(index);
                  },
                  child: Card(
                    color: logs[index].getColor(context),
                    // Use the getColor() method
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IntrinsicWidth(
                      child: Container(
                        height: 30, // Card height
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(logs[index]
                              .toString()), // Use the `toString` method of LogEntry
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget createBody(
      BuildContext context, WidgetRef ref, String? selectedSymbol) {
    if (selectedSymbol == null) {
      return const Center();
    }

    return Center(
      child: RotatedBox(
        quarterTurns: 1,
        child: Container(
          height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            // Rounds the edges of the container
            border: Border.all(
              color: Theme.of(context).cardColor,
              width: 2.0, // Set border width
            ),
          ),
          child: Column(
            children: [
              // Space for the list of cards and button
              Padding(
                padding: const EdgeInsets.all(8.0),
                // Add padding for aesthetics
                child: createToolBar(context, ref),
              ),
              Divider(
                color: Theme.of(context).cardColor,
              ), // Separator line (optional)
              createLogsTable(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget createLogsTable(BuildContext context, WidgetRef ref) {
    final logsState = ref.watch(auditLogsNotifierProvider);
    return logsState.when(
      data: (logs) => _createLogsTable(context, ref, logs),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Error: $err'),
      ),
    );
  }

  Widget _createLogsTable(
      BuildContext context, WidgetRef ref, List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) {
      return const Text('No logs found');
    }
    final columns = logs.first.keys.toList();
    final columnWidths = ref.watch(logsTableColumnWidthsProvider);
    return Expanded(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                // Center-align vertically
                columnWidths: {
                  for (int i = 0; i < columnWidths.length; i++)
                    i: FlexColumnWidth(columnWidths[i]),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Theme.of(context).cardColor,
                  ),
                  verticalInside: BorderSide(
                    color: Theme.of(context).cardColor,
                  ),
                  bottom: BorderSide(
                    color: Theme.of(context).cardColor,
                  ),
                ),
                children: [
                  TableRow(
                      children: columns
                          .map((header) => headerCell(context, ref, header, 0))
                          .toList()),
                  ...List.generate(logs.length, (index) {
                    final auditLog = logs[index];
                    final isEvenRow = index.isEven;
                    return TableRow(
                        decoration: BoxDecoration(
                          color: isEvenRow
                              ? Theme.of(context)
                                  .highlightColor // Even row color
                              : Colors.transparent, // Default for odd rows
                        ),
                        children: auditLog.values
                            .toList()
                            .map((value) => Text(
                                  value.toString(),
                                  textAlign: TextAlign.center,
                                ))
                            .toList());
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerCell(
      BuildContext context, WidgetRef ref, String label, int index) {
    return GestureDetector(
      onDoubleTap: () {
        ref.read(logsTableColumnWidthsProvider.notifier).incrementWidth(index);
      },
      onLongPress: () {
        ref.read(logsTableColumnWidthsProvider.notifier).decrementWidth(index);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, WidgetRef ref,
      {AuditColumnSettings? columnSetting, int? index}) {
    final TextEditingController columnController =
        TextEditingController(text: columnSetting?.column ?? '');
    final TextEditingController valueController =
        TextEditingController(text: columnSetting?.value ?? '');
    String selectedOption = columnSetting?.query ?? 'select';
    String selectedOperator = columnSetting?.operator ?? '==';
    bool addSelectField = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Query Audit Logs'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: Theme.of(context).cardColor,
                      value: selectedOption,
                      items: const [
                        DropdownMenuItem(
                          value: 'select',
                          child: Text('Select'),
                        ),
                        DropdownMenuItem(
                          value: 'where',
                          child: Text('Where'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedOption = newValue;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: columnController,
                      decoration: const InputDecoration(
                        hintText: 'Column',
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(
                          color:
                              Colors.grey, // Set your desired hint text color
                        ),
                      ),
                    ),
                    if (selectedOption == 'where') ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              dropdownColor: Theme.of(context).cardColor,
                              value: selectedOperator,
                              items: const [
                                DropdownMenuItem(
                                  value: '>',
                                  child: Text('>'),
                                ),
                                DropdownMenuItem(
                                  value: '>=',
                                  child: Text('>='),
                                ),
                                DropdownMenuItem(
                                  value: '==',
                                  child: Text('=='),
                                ),
                                DropdownMenuItem(
                                  value: '<',
                                  child: Text('<'),
                                ),
                                DropdownMenuItem(
                                  value: '<=',
                                  child: Text('<='),
                                ),
                                DropdownMenuItem(
                                  value: '!=',
                                  child: Text('!='),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedOperator = newValue;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: 'Operator',
                                border: OutlineInputBorder(),
                                hintStyle: TextStyle(
                                  color: Colors
                                      .grey, // Set your desired hint text color
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: valueController,
                              decoration: const InputDecoration(
                                hintText: 'Value',
                                border: OutlineInputBorder(),
                                hintStyle: TextStyle(
                                  color: Colors
                                      .grey, // Set your desired hint text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: addSelectField,
                            onChanged: (bool? value) {
                              setState(() {
                                addSelectField = value ?? false;
                              });
                            },
                          ),
                          const Text('Add select field'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Colors.white, // Sets the text color to white
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String column = columnController.text;
                    final String value = valueController.text;
                    if (index != null) {
                      ref.read(logsProvider.notifier).updateQuery(
                            index,
                            AuditColumnSettings(
                              query: selectedOption,
                              column: column,
                              operator: selectedOption == 'where'
                                  ? selectedOperator
                                  : null,
                              value: selectedOption == 'where' ? value : null,
                            ),
                          );
                    } else {
                      ref
                          .read(logsProvider.notifier)
                          .addQuery(AuditColumnSettings(
                            query: selectedOption,
                            column: column,
                            operator: selectedOption == 'where'
                                ? selectedOperator
                                : null,
                            value: selectedOption == 'where' ? value : null,
                          ));
                    }
                    if (addSelectField) {
                      ref
                          .read(logsProvider.notifier)
                          .addQuery(AuditColumnSettings(
                            query: 'select',
                            column: column,
                          ));
                    }

                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
