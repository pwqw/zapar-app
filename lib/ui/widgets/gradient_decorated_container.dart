import 'package:flutter/material.dart';

class GradientDecoratedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GradientDecoratedContainer(
      {Key? key, this.child = const SizedBox.expand(), this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Zapar brand gradient: negro profundo con tinte verde desde la esquina
    // inferior-izquierda hacia el fondo oscuro sólido de la app.
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
