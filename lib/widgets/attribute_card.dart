import 'package:flutter/material.dart';

class AttributeCard extends StatelessWidget {
  final String name;
  final String value;

  const AttributeCard({
    super.key,
    required this.name,
    this.value = '',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthOfCard(),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double widthOfCard() {
    const double widthPerChar = 105 / 11;
    double totalWidth =
        widthPerChar * (name.length + value.length);
    if (value.isNotEmpty) {
      totalWidth += widthPerChar;
    }
    return totalWidth;
  }
}
