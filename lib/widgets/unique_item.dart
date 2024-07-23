import 'package:flutter/material.dart';
import 'package:jessica/custom_theme_extension.dart';

class UniqueItem extends StatelessWidget {
  final String numberPrefix;
  final String keyText;
  final dynamic value;
  final int level;
  final List<int> parentIndices;
  final bool hasChildren;

  const UniqueItem({
    Key? key,
    required this.numberPrefix,
    required this.keyText,
    required this.value,
    required this.level,
    required this.parentIndices,
    this.hasChildren = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hasChildren) {
      return Container(
        margin: EdgeInsets.only(left: level * 16.0),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Text(
              numberPrefix,
              style: Theme.of(context).expansionTileLeading,
            ),
            title: Text(
              keyText.isNotEmpty ? keyText : value.toString(),
              style: Theme.of(context).expansionTileTitle,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            collapsedIconColor:
                Theme.of(context).colorScheme.onSecondaryContainer,
            iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
            children: _buildChildren(context, value, level, parentIndices),
          ),
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
            keyText.isNotEmpty ? keyText : value.toString(),
            style: Theme.of(context).listTileTitle,
          ),
          subtitle: keyText.isNotEmpty
              ? Text(value.toString(),
                  style: Theme.of(context).listTileSubtitle)
              : null,
        ),
      );
    }
  }

  List<Widget> _buildChildren(
      BuildContext context, dynamic value, int level, List<int> parentIndices) {
    List<Widget> childrenWidgets = [];

    if (value is Map) {
      childrenWidgets =
          value.entries.toList().asMap().entries.map((indexedEntry) {
        var entry = indexedEntry.value;
        return UniqueItem(
          numberPrefix: '',
          keyText: entry.key,
          value: entry.value,
          level: level + 1,
          parentIndices: parentIndices,
          hasChildren: entry.value is Map || entry.value is List,
        );
      }).toList();
    } else if (value is List) {
      childrenWidgets = value.asMap().entries.map<Widget>((entry) {
        return UniqueItem(
          numberPrefix: '',
          keyText: '',
          value: entry.value,
          level: level + 1,
          parentIndices: parentIndices,
          hasChildren: entry.value is Map || entry.value is List,
        );
      }).toList();
    }

    return childrenWidgets;
  }
}
