import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoCompleteField extends StatefulWidget {
  @override
  _AutoCompleteFieldState createState() => _AutoCompleteFieldState();
}

class _AutoCompleteFieldState extends State<AutoCompleteField> {
  final TextEditingController columnController = TextEditingController();
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('autocomplete_history') ?? [];
    });
  }

  Future<void> _saveToHistory(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Add the new value, ensuring no duplicates and limiting to 10 items
    setState(() {
      if (value.isNotEmpty && !history.contains(value)) {
        history.insert(0, value); // Add to the beginning
        if (history.length > 10) {
          history = history.sublist(0, 10); // Keep only the last 10
        }
      }
    });

    await prefs.setStringList('autocomplete_history', history);
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return history.where((option) =>
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        columnController.text = selection;
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller: fieldTextEditingController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            hintText: 'Column',
            border: OutlineInputBorder(),
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
          ),
          onSubmitted: (value) {
            _saveToHistory(value);
          },
        );
      },
    );
  }
}
