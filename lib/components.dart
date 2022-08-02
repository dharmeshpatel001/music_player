import 'package:flutter/material.dart';

class Components {
  //bg Color
  Color bgColor = const Color(0xFF2C3333);
  Color bgSubText = const Color(0xFFE7F6F2);
  Color bgApp = const Color(0xFF7F8487);
  Color bgText = const Color(0xFFA5C9CA);

  void toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    ));
  }

  getDecoration(
      BoxShape shape, Offset offset, double blurRadius, double spreadRadius) {
    return BoxDecoration(color: bgColor, shape: shape, boxShadow: [
      BoxShadow(
          offset: -offset,
          color: Colors.white24,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius),
      BoxShadow(
          offset: offset,
          color: Colors.black,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius)
    ]);
  }

  getRectDecoration(BorderRadius borderRadius, Offset offset, double blurRadius,
      double spreadRadius) {
    return BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
              offset: -offset,
              color: Colors.white24,
              blurRadius: blurRadius,
              spreadRadius: spreadRadius),
          BoxShadow(
              offset: offset,
              color: Colors.black,
              blurRadius: blurRadius,
              spreadRadius: spreadRadius)
        ]);
  }

}