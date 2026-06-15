import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 30,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.7,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 25,
    height: 1.2,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.35,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(fontSize: 15, height: 1.5);

  static const TextStyle bodySmall = TextStyle(fontSize: 13, height: 1.4);

  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
}
