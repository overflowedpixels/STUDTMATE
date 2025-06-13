import 'package:flutter/services.dart';

class FocusHelper {
  static const MethodChannel _channel = MethodChannel("focus_mode");

  static Future<void> enableFocusMode() async {
    await _channel.invokeMethod("keepScreenOn");
  }

  static Future<void> disableFocusMode() async {
    await _channel.invokeMethod("allowSleep");
  }
}
