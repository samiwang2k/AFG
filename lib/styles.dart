import 'package:flutter/material.dart';

const colorBlack = Color.fromRGBO(48, 47, 48, 1.0);
const colorGray = Color.fromRGBO(141, 141, 141, 1.0);
const colorWhite = Colors.white;

const TextTheme textThemeDefault = TextTheme(
  displayLarge:
      TextStyle(color: colorBlack, fontWeight: FontWeight.w700, fontSize: 26),
  displayMedium:
      TextStyle(color: colorBlack, fontWeight: FontWeight.w700, fontSize: 22),
  displaySmall:
      TextStyle(color: colorBlack, fontWeight: FontWeight.w700, fontSize: 20),
  headlineMedium:
      TextStyle(color: colorBlack, fontWeight: FontWeight.w700, fontSize: 16),
  headlineSmall:
      TextStyle(color: colorBlack, fontWeight: FontWeight.w700, fontSize: 14),
  titleLarge:
      TextStyle(color: colorBlack, fontWeight: FontWeight.w700, fontSize: 12),
  bodyLarge: TextStyle(
      color: colorBlack,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.5),
  bodyMedium: TextStyle(
      color: colorGray, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
  titleMedium:
      TextStyle(color: colorBlack, fontSize: 12, fontWeight: FontWeight.w400),
  titleSmall:
      TextStyle(color: colorGray, fontSize: 12, fontWeight: FontWeight.w400),
);
