import 'package:flutter/material.dart';

class GeneralParamsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  GeneralParamsPage({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> global_params_data = {};
    try {
      global_params_data = data["general"];
    } catch (e) {
      // Handle error if needed
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: global_params_data.length,
        itemBuilder: (context, index) {
          String key = global_params_data.keys.elementAt(index);
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                key,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              subtitle: Text(
                global_params_data[key].toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
