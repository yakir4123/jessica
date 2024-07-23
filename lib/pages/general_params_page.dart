import 'package:flutter/material.dart';
import 'package:jessica/widgets/general_card.dart';

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
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 16.0, // Horizontal spacing between grid items
                mainAxisSpacing: 16.0, // Vertical spacing between grid items
                childAspectRatio:
                    7 / 4, // Ratio of width to height for each grid item
              ),
              itemCount: global_params_data.length,
              itemBuilder: (context, index) {
                String key = global_params_data.keys.elementAt(index);
                return GeneralCard(
                  title: key,
                  subtitle: global_params_data[key].toString(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
