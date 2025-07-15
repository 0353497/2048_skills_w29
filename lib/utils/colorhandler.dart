import 'package:flutter/material.dart';

class ColorHandler {
  static Color getColorFromValue(int value) {
    switch (value) {
      case 0 :
      return Colors.white;
      case 2:
        return Color(0xffe1ccb7);
      case 4:
        return Color(0xffe6c3a1);
      case 8:
        return Color(0xffdfad7a);
      case 16:
        return Color(0xffd86a54);
      case 32:
        return Color(0xffe43c3c);
      case 64:
        return Color(0xffe528b9);
      case 128:
        return Color(0xffcc28e5);
      case 256:
        return Color(0xff7028e5);
      case 512:
        return Color(0xff1c64bd);
      case 1024:
        return Color(0xff1cbd67);
      case 2048:
        return Color(0xff12991f);
      default:
        return Color(0xff095510);
    }
  }

  static Color getTextColorFromValue(int value) {
    if (value <= 8) {
      return Color(0xff777777);
    }
    return Colors.white;
  }
}