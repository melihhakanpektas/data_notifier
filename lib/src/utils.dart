import 'package:data_notifier/src/print_color.dart';
import 'package:flutter/foundation.dart';

// Temel stil komutları
const kCmdReset = '\x1b[0m'; // Tüm stilleri sıfırla
const kCmdBold = '\x1b[1m'; // Kalın
const kCmdBlink = '\x1b[5m'; // Yanıp sönen

void kMyDebugPrint(String message, {PrintColor? color, bool blink = false}) {
  final kCmdStyle = '$kCmdBold${blink ? kCmdBlink : ''}';
  if (kDebugMode == false) return;
  final cmdStyle = '$kCmdStyle${color != null ? "\x1b[${color.code}m" : ''}';
  debugPrint('$cmdStyle$message$kCmdReset');
}
