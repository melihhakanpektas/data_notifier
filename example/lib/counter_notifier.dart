import 'package:data_notifier/data_notifier.dart';

class CounterNotifier extends DataNotifier<int> {
  CounterNotifier._() : super.loading() {
    load(_fetchCounter);
  }

  /// Simulates fetching the counter from a remote source.
  static Future<int> _fetchCounter() async {
    await Future.delayed(const Duration(seconds: 2));
    return 0;
  }

  /// Instance of the CounterNotifier
  /// This is a singleton instance, so it can be used throughout the app.
  /// Starts when you call `CounterNotifier.instance`
  /// You can use this instance to listen to changes in the counter value.
  static final CounterNotifier instance = CounterNotifier._();

  /// Increments the counter value by 1.
  void increment() {
    final data = value.dataOrNull;
    if (data != null) setLoaded(data + 1);
  }

  /// Decrements the counter value by 1.
  void decrement() {
    final data = value.dataOrNull;
    if (data != null) setLoaded(data - 1);
  }

  /// Switches to an error state when loaded, and back to a loaded state
  /// when in error. Demonstrates native pattern matching on the sealed
  /// [NotifierState] class.
  void errorOrFix() {
    switch (value) {
      case NotifierStateLoaded<int>():
        setError(Exception('An error occurred'), 'An error occurred');
      case NotifierStateError<int>():
        setLoaded(0);
      case NotifierStateLoading<int>():
        break;
    }
  }

  /// Reloads the counter. While the reload is in progress, the previous
  /// value stays available via `state.dataOrPrevious`.
  void reload() => load(_fetchCounter);
}
