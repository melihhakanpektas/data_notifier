import 'package:data_notifier/src/notifier_state.dart';
import 'package:data_notifier/src/print_color.dart';
import 'package:data_notifier/src/utils.dart';
import 'package:flutter/foundation.dart';

/// A [ValueNotifier] that holds a [NotifierState] of [D] and provides
/// convenience setters for the loading, loaded, and error states.
///
/// In debug mode (when [debugConsoleLogs] is `true`), every state change is
/// printed to the console with a color matching the state, which makes it
/// easy to follow state transitions during development.
class DataNotifier<D> extends ValueNotifier<NotifierState<D>> {
  /// Controls whether state changes are logged to the debug console.
  ///
  /// Logging only happens in debug mode ([kDebugMode]); this flag has no
  /// effect in profile or release builds. Defaults to `true`.
  final bool debugConsoleLogs;

  final String? _debugLabel;

  /// Creates a [DataNotifier] with the given initial [value].
  ///
  /// [debugLabel] is used as the prefix of debug console logs; when omitted,
  /// the runtime type of the notifier is used instead.
  DataNotifier(super.value, {this.debugConsoleLogs = true, String? debugLabel})
    : _debugLabel = debugLabel {
    if (kDebugMode && debugConsoleLogs) {
      addListener(_statusListener);
    }
  }

  /// Creates a [DataNotifier] that starts in the loading state.
  DataNotifier.loading({bool debugConsoleLogs = true, String? debugLabel})
    : this(
        NotifierStateLoading<D>(),
        debugConsoleLogs: debugConsoleLogs,
        debugLabel: debugLabel,
      );

  String get _label => _debugLabel ?? '$runtimeType';

  bool _disposed = false;
  int _loadId = 0;

  /// Whether [dispose] has been called on this notifier.
  bool get isDisposed => _disposed;

  /// Sets the state to [NotifierStateLoading].
  ///
  /// The data of the current state (if any) is carried over as
  /// [NotifierStateLoading.previousData], so the UI can keep showing stale
  /// data while a refresh is in progress. Set [preserveData] to `false` to
  /// discard it.
  void setLoading({bool preserveData = true}) =>
      value = NotifierStateLoading<D>(
        previousData: preserveData ? value.dataOrPrevious : null,
      );

  /// Sets the state to [NotifierStateLoaded] with the given [data].
  void setLoaded(D data) => value = NotifierStateLoaded<D>(data);

  /// Sets the state to [NotifierStateError] with the given [error],
  /// [message], and optional [stackTrace].
  ///
  /// The data of the current state (if any) is carried over as
  /// [NotifierStateError.previousData]. Set [preserveData] to `false` to
  /// discard it.
  void setError(
    Object? error,
    String message, {
    StackTrace? stackTrace,
    bool preserveData = true,
  }) => value = NotifierStateError<D>(
    error,
    message,
    stackTrace: stackTrace,
    previousData: preserveData ? value.dataOrPrevious : null,
  );

  /// Runs [fetch] and reflects its outcome on this notifier.
  ///
  /// Sets the state to loading (carrying over the current data as
  /// [NotifierStateLoading.previousData]), awaits [fetch], and then sets a
  /// loaded state with the result — or an error state if [fetch] throws.
  /// [errorMessage] overrides the message of the error state; by default the
  /// thrown error's `toString()` is used.
  ///
  /// Safe against overlapping calls and disposal:
  /// - If [load] is called again before a previous call completes, the stale
  ///   result is discarded (latest call wins).
  /// - If the notifier is disposed while [fetch] is in flight, the result is
  ///   discarded instead of throwing.
  Future<void> load(Future<D> Function() fetch, {String? errorMessage}) async {
    final loadId = ++_loadId;
    setLoading();
    try {
      final data = await fetch();
      if (_disposed || loadId != _loadId) return;
      setLoaded(data);
    } catch (e, s) {
      if (_disposed || loadId != _loadId) return;
      setError(e, errorMessage ?? '$e', stackTrace: s);
    }
  }

  void _statusListener() {
    switch (value) {
      case NotifierStateLoading<D>():
        kMyDebugPrint('$_label: Loading', color: PrintColor.yellow);
      case NotifierStateLoaded<D>(data: final data):
        if (data is List) {
          kMyDebugPrint(
            '$_label: Loaded ${data.length} items',
            color: PrintColor.green,
          );
        } else {
          kMyDebugPrint('$_label: Loaded data $data', color: PrintColor.green);
        }
      case NotifierStateError<D>(message: final message):
        kMyDebugPrint('$_label: Error $message', color: PrintColor.red);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (kDebugMode && debugConsoleLogs) {
      removeListener(_statusListener);
    }
    super.dispose();
  }
}
