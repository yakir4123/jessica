import 'package:flutter/material.dart';
import 'custom_theme_extension.dart';

class UniqueParamsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  UniqueParamsPage({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> unique_params_data = {};
    try {
      unique_params_data = data["unique"];
    } catch (e) {}

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: unique_params_data.entries
            .toList()
            .asMap()
            .entries
            .map((indexedEntry) {
          int index = indexedEntry.key;
          var entry = indexedEntry.value;
          return _buildItem(context, index, entry.key, entry.value, 0, []);
        }).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, String key, dynamic value,
      int level, List<int> parentIndices) {
    List<int> currentIndices = List.from(parentIndices)..add(index);
    String numberPrefix = currentIndices.join('.');

    if (value is Map || value is List) {
      return Container(
        margin: EdgeInsets.only(left: level * 16.0),
        child: ExpansionTile(
          leading: Text(
            numberPrefix,
            style: Theme.of(context).expansionTileLeading,
          ),
          title: Text(
            key.isNotEmpty ? key : value.toString(),
            style: Theme.of(context).expansionTileTitle,
          ),
          collapsedIconColor:
              Theme.of(context).colorScheme.onSecondaryContainer,
          iconColor: Theme.of(context)
              .colorScheme
              .onSecondaryContainer,
          children: _buildChildren(context, value, level, currentIndices),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(left: level * 16.0),
        child: ListTile(
          leading: Text(
            numberPrefix,
            style: Theme.of(context).listTileLeading,
          ),
          title: Text(
            key.isNotEmpty ? key : value.toString(),
            style: Theme.of(context).listTileTitle,
          ),
          subtitle: key.isNotEmpty
              ? Text(value.toString(),
                  style: Theme.of(context).listTileSubtitle)
              : null,
        ),
      );
    }
  }

  List<Widget> _buildChildren(
      BuildContext context, dynamic value, int level, List<int> parentIndices) {
    if (value is Map) {
      return value.entries.toList().asMap().entries.map((indexedEntry) {
        int index = indexedEntry.key;
        var entry = indexedEntry.value;
        return _buildItem(
            context, index, entry.key, entry.value, 0, parentIndices);
      }).toList();
    } else if (value is List) {
      return value
          .asMap()
          .entries
          .map<Widget>((entry) => _buildItem(
                context,
                entry.key + 1,
                '',
                entry.value,
                level + 1,
                parentIndices,
              ))
          .toList();
    } else {
      return [];
    }
  }
}
