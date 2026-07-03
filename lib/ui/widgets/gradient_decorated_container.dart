import 'package:flutter/material.dart';

class GradientDecoratedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GradientDecoratedContainer(
      {Key? key, this.child = const SizedBox.expand(), this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Brand gradient: deep black with green tint from bottom-left corner
    // towards the solid dark app background.
    return Container(
      child: child,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomLeft,
          radius: 1.4,
          colors: [
            Color(0xFF0F3020), // verde oscuro (#19D163 desaturado)
            Color(0xFF0A1F14),
            Color(0xFF181818), // fondo base
          ],
          stops: [0.0, 0.35, 1.0],
        ),
      ),
    );
  }
}
