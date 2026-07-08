import 'package:data_notifier/src/print_color.dart';
import 'package:flutter/foundation.dart';

const _kCmdReset = '\x1b[0m';
const _kCmdBold = '\x1b[1m';

/// Prints [message] to the debug console in bold, optionally colored with
/// [color]. Does nothing outside of debug mode.
void kMyDebugPrint(String message, {PrintColor? color}) {
  if (!kDebugMode) return;
  final cmdStyle = '$_kCmdBold${color != null ? "\x1b[${color.code}m" : ''}';
  debugPrint('$cmdStyle$message$_kCmdReset');
}
