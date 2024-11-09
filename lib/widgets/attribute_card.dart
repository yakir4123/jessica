import 'package:flutter/material.dart';

class AttributeCard extends StatelessWidget
    implements Comparable<AttributeCard> {
  final String name;
  final String value;

  const AttributeCard({
    super.key,
    required this.name,
    this.value = '',
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              if (value.isNotEmpty)
                const SizedBox(width: 8.0), // Space between key and value
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  int compareTo(AttributeCard other) {
    // Use calculated width or fallback to 0 if not calculated yet.
    return estimatedWidthOfCard().compareTo(estimatedWidthOfCard());
  }

  double estimatedWidthOfCard() {
    return 7 * (name.length + value.length) + //estimate text width
        16 + // card padding
        8 + // space between
        (value.isNotEmpty ? 8 : 0); // space between name + value
  }
}
