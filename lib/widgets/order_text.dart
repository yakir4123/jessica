import 'package:flutter/material.dart';
import 'package:jessica/custom_theme_extension.dart';

class OrderText extends StatelessWidget {
  final String text;

  const OrderText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .listTileLeading
          .copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
    );
  }
}
