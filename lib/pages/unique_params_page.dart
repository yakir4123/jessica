import 'package:flutter/material.dart';
import 'package:jessica/widgets/unique_item.dart';

class UniqueParamsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  UniqueParamsPage({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> uniqueParamsData = {};
    try {
      uniqueParamsData = data["unique"];
    } catch (e) {
      // Handle error if needed
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: uniqueParamsData.entries
            .toList()
            .asMap()
            .entries
            .map((indexedEntry) {
          int index = indexedEntry.key;
          var entry = indexedEntry.value;
          return UniqueItem(
            numberPrefix: (index + 1).toString(),
            keyText: entry.key,
            value: entry.value,
            level: 0,
            parentIndices: [],
            hasChildren: entry.value is Map || entry.value is List,
          );
        }).toList(),
      ),
    );
  }
}
