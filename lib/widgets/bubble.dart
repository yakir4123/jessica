import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BubbleWidget extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap; // Optional callback
  const BubbleWidget({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: ClipPath(
          clipper: BubbleClipper(),
          child: Container(
            padding: const EdgeInsets.all(10),
            color: Theme.of(context).cardColor,
            width: 40,
            height: 60,
            child: icon,
          ),
        ),
      ),
    );
  }
}

class BubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 12.0;

    // Draw rounded rectangle with a tail at the bottom left
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
    path.lineTo(20, size.height); // Draw to where the tail starts
    path.lineTo(10, size.height + 10); // Tail point
    path.lineTo(10, size.height); // Back to the rectangle
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
