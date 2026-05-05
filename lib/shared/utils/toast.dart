import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void show({String? message}) {
    Fluttertoast.showToast(
      msg: message ?? "Something went wrong. Please try again",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      textColor: const Color(0xFFF8FAFC),
    );
  }
}