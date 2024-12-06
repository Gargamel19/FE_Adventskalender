import 'package:flutter/material.dart';
import 'package:test_app/main.dart';

void showSnackBar(
    String message, {Duration duration = const Duration(seconds: 2), Color backgroundColor = Colors.white38, Color textColor = Colors.black}) {
  MainApp.scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message, style: TextStyle(color: textColor)), backgroundColor: backgroundColor, duration: duration),
  );
}
