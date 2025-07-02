import 'package:data_notifier/src/cmd_color.dart';
import 'package:data_notifier/src/data_state.dart';
import 'package:data_notifier/src/utils.dart';
import 'package:flutter/foundation.dart';

/// A custom notifier that extends ValueNotifier to provide additional functionality.
/// This notifier notifies listeners when the value changes, even if the scheduler phase is not idle.
/// So if the value is set during a frame, it will notify listeners after the frame is complete.
/// This is useful for ensuring that UI updates are made after the current frame is rendered.
///
/// Enables or disables logging of the notifier's state changes to the debug console.
/// When set to `true`, all state updates will be printed to the console for debugging purposes.
/// Useful for tracking state changes during development.
/// It also provides a debug listener that prints the current state of the notifier to the console.
class DataNotifier<T extends DataState> extends ValueNotifier<T> {
  /// The [debugConsoleLogs] parameter controls whether the notifier logs its state changes to the
  /// debug console when kDebugMode is true.
  /// When set to `true`, it will print the current state of the notifier to the
  /// console whenever the state changes.
  /// This is useful for debugging and tracking the state of the notifier during development.
  /// By default, it is set to `true`.
  final bool debugConsoleLogs;

  DataNotifier(super.value, {this.debugConsoleLogs = true}) {
    if (kDebugMode && debugConsoleLogs) {
      super.addListener(_statusListener);
    }
  }
  void _statusListener() {
    return super.value.maybeWhen(
      loading: () {
        kMyDebugPrint('$T: Loading', color: PrintColor.yellow); // Sarı
      },
      error: (error, message) {
        kMyDebugPrint(
          '$T: Error $message',
          color: PrintColor.red,
          blink: true,
        ); // Kırmızı
      },
      loaded: (data) {
        if (data is List) {
          kMyDebugPrint(
            '$T: Loaded ${data.length} items',
            color: PrintColor.green,
          ); // Yeşil
        } else {
          kMyDebugPrint(
            '$T: Loaded data $data',
            color: PrintColor.green,
          ); // Yeşil
        }
      },
    );
  }

  void cancel() {}

  @override
  void dispose() {
    if (kDebugMode && debugConsoleLogs) {
      removeListener(_statusListener);
    }
    super.dispose();
  }
}
