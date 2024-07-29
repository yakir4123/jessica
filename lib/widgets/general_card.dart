import 'package:flutter/material.dart';

class GeneralCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const GeneralCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Adds shadow to the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      margin: EdgeInsets.zero, // Remove margin from card
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
