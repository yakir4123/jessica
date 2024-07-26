import 'package:flutter/material.dart';
import 'package:jessica/widgets/general_card.dart';

class GeneralParamsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  Map<String, dynamic> globalParamsData = {};

  GeneralParamsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    try {
      globalParamsData = data["general"];
    } catch (e) {
      // Handle error if needed
      globalParamsData = {
        "update-time": 0,
        "today-pnl": 0,
        "balance": 0,
        "available-margin": 0
      };
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
                    6 / 4, // Ratio of width to height for each grid item
              ),
              itemCount: globalParamsData.length,
              itemBuilder: (context, index) {
                String key = globalParamsData.keys.elementAt(index);
                return GeneralCard(
                  title: key,
                  subtitle: formatItem(key),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatItem(String key) {
    List<String> validKeys = [
      'update-time',
      'today-pnl',
      'balance',
      'available-margin',
    ];
    if (!validKeys.contains(key)) {
      return "";
    }
    DateTime updateTime =
        DateTime.fromMillisecondsSinceEpoch(globalParamsData["update-time"]);

    // Format the numbers with one decimal place
    String todayPnl = globalParamsData['today-pnl'].toStringAsFixed(1);
    String balance = globalParamsData['balance'].toStringAsFixed(1);
    String availableMargin =
        globalParamsData['available-margin'].toStringAsFixed(1);

    // Create the response map
    Map<String, String> resp = {
      'update-time': updateTime.toString(),
      'today-pnl': todayPnl,
      'balance': balance,
      'available-margin': availableMargin,
    };
    return resp[key]!;
  }
}
