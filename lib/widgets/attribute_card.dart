import 'package:flutter/material.dart';

class AttributeCard extends StatefulWidget
    implements Comparable<AttributeCard> {
  final String name;
  final String value;

  const AttributeCard({
    super.key,
    required this.name,
    this.value = '',
  });

  @override
  State<AttributeCard> createState() => _AttributeCardState();

  @override
  int compareTo(AttributeCard other) {
    // Use calculated width or fallback to 0 if not calculated yet.
    return widthOfCard().compareTo(widthOfCard());
  }

  double widthOfCard() {
    return _AttributeCardState._getCalculatedWidth(this) ?? 0;
  }
}

class _AttributeCardState extends State<AttributeCard> {
  static final Map<Key, double> _calculatedWidths = {};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final width = _calculateWidth(context);
          _calculatedWidths[widget.key!] = width;
        });

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
                    widget.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                  ),
                  const SizedBox(width: 8.0), // Space between key and value
                  if (widget.value.isNotEmpty)
                    Text(
                      widget.value,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateWidth(BuildContext context) {
    // Use TextPainter to calculate the exact width of the text.
    final TextPainter namePainter = TextPainter(
      text: TextSpan(
        text: widget.name,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final TextPainter valuePainter = TextPainter(
      text: TextSpan(
        text: widget.value,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontStyle: FontStyle.italic,
            ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return namePainter.width +
        (widget.value.isNotEmpty ? valuePainter.width + 8.0 : 0);
  }

  static double? _getCalculatedWidth(AttributeCard card) {
    return _calculatedWidths[card.key] ?? 0;
  }
}
