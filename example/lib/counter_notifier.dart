import 'package:data_notifier/data_notifier.dart';

class CounterNotifier extends DataNotifier<NotifierState<int, int>> {
  CounterNotifier._() : super(const NotifierStateLoading()) {
    // Fake loading data
    Future.delayed(const Duration(seconds: 5), () {
      value = NotifierStateLoaded(0);
    });
  }

  /// Instance of the CounterNotifier
  /// This is a singleton instance, so it can be used throughout the app.
  /// Starts when you call `CounterNotifier.instance`
  /// Ends when you call `CounterNotifier.instance.cancel()`
  /// You can use this instance to listen to changes in the counter value.
  static final CounterNotifier instance = CounterNotifier._();

  /// Increments the counter value by 1.
  void increment() {
    value = value.whenOrElse(
      loading: () => const NotifierStateLoading(),
      loaded: (data) => NotifierStateLoaded(data + 1),
      error: (error, message) => NotifierStateError(error, message),
      orElse: () => const NotifierStateLoading(),
    );
  }

  /// Decrements the counter value by 1.
  void decrement() {
    value = value.whenOrElse(
      loading: () => const NotifierStateLoading(),
      loaded: (data) => NotifierStateLoaded(data - 1),
      error: (error, message) => NotifierStateError(error, message),
      orElse: () => const NotifierStateLoading(),
    );
  }

  void errorOrFix() {
    value = value.whenOrElse(
      loading: () => const NotifierStateLoading(),
      loaded: (data) => NotifierStateError(Exception('An error occurred'), 'An error occurred'),
      error: (error, message) {
        // Simulate fixing the error
        return NotifierStateLoaded(0);
      },
      orElse: () => const NotifierStateLoading(),
    );
  }
}
