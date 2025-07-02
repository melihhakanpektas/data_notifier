import 'package:data_notifier/data_notifier.dart';

class CounterNotifier extends DataNotifier<DataState<int, int>> {
  CounterNotifier._() : super(const DataStateLoading(), debugConsoleLogs: false) {
    // Fake loading data
    Future.delayed(const Duration(seconds: 5), () {
      value = DataStateLoaded(0);
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
      loading: () => const DataStateLoading(),
      loaded: (data) => DataStateLoaded(data + 1),
      error: (error, message) => DataStateError(error, message),
      orElse: () => const DataStateLoading(),
    );
  }

  /// Decrements the counter value by 1.
  void decrement() {
    value = value.whenOrElse(
      loading: () => const DataStateLoading(),
      loaded: (data) => DataStateLoaded(data - 1),
      error: (error, message) => DataStateError(error, message),
      orElse: () => const DataStateLoading(),
    );
  }

  void errorOrFix() {
    value = value.whenOrElse(
      loading: () => const DataStateLoading(),
      loaded: (data) => DataStateError(Exception('An error occurred'), 'An error occurred'),
      error: (error, message) {
        // Simulate fixing the error
        return DataStateLoaded(0);
      },
      orElse: () => const DataStateLoading(),
    );
  }

  void loadingForASecond() {
    // Simulate a loading state for 1 second
    value = value.whenOrElse(
      loading: () => const DataStateLoading(),
      loaded: (data) => const DataStateLoading(),
      error: (error, message) => const DataStateLoading(),
      orElse: () => const DataStateLoading(),
    );
    Future.delayed(const Duration(seconds: 1), () {
      value = DataStateLoaded(0);
    });
  }
}
