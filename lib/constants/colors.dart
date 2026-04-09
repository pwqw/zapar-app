import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // this basically makes it so you can't instantiate this class

  static const black = const Color(0xFF181818);
  static const white = const Color(0xFFFFFFFF);
  static const red = const Color(0xFFBF2043);

  static const text = Color.fromRGBO(255, 255, 255, .9);
  static const background = AppColors.black;
  static const highlight = const Color(0xFF19D163);
  static const highlightAccent = const Color(0xFF14A84F);

  static const staticScreenHeaderBackground = Colors.transparent;
  static const flexibleScreenHeaderBackground = Color.fromRGBO(0, 30, 15, .5);
}
