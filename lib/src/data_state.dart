/// Base class representing the state of a notifier.
///
/// [T] is the type of the notifier, [D] is the type of the data.
/// This class is intended to be extended by specific state implementations
/// such as [DataStateLoading], [DataStateLoaded], and [DataStateError].
abstract class DataState<T, D> {
  /// Private constructor to prevent direct instantiation.
  const DataState._();

  /// Pattern matching for all state types.
  ///
  /// Requires a callback for each possible state.
  /// - [loading]: Called when the state is [DataStateLoading].
  /// - [loaded]: Called when the state is [DataStateLoaded], provides the loaded data.
  /// - [error]: Called when the state is [DataStateError], provides the error message.
  W when<W>({
    required W Function() loading,
    required W Function(D data) loaded,
    required W Function(String message) error,
  }) {
    if (this is DataStateLoading) {
      return loading();
    } else if (this is DataStateLoaded) {
      return loaded.call((this as DataStateLoaded<T, D>).data);
    } else if (this is DataStateError) {
      return error((this as DataStateError).message);
    } else {
      throw Exception("Unknown state: $this");
    }
  }

  /// Pattern matching for state types, with optional callbacks.
  ///
  /// Returns the result of the matching callback, or [orElse] if provided and no match is found.
  /// - [loading]: Optional callback for [DataStateLoading].
  /// - [loaded]: Optional callback for [DataStateLoaded], provides the loaded data.
  /// - [error]: Optional callback for [DataStateError], provides the error and message.
  /// - [orElse]: Optional fallback callback if no match is found.
  W? maybeWhen<W>({
    W Function()? loading,
    W Function(D data)? loaded,
    W Function(dynamic error, String message)? error,
    W Function()? orElse,
  }) {
    if (this is DataStateLoading) {
      return loading?.call();
    } else if (this is DataStateLoaded) {
      return loaded?.call((this as DataStateLoaded<T, D>).data);
    } else if (this is DataStateError) {
      return error?.call((this as DataStateError).error, (this as DataStateError).message);
    }
    return orElse?.call();
  }

  /// Pattern matching for state types, with a required fallback.
  ///
  /// Returns the result of the matching callback, or [orElse] if no match is found.
  /// - [loading]: Optional callback for [DataStateLoading].
  /// - [loaded]: Optional callback for [DataStateLoaded], provides the loaded data.
  /// - [error]: Optional callback for [DataStateError], provides the error and message.
  /// - [orElse]: Required fallback callback if no match is found.
  W whenOrElse<W>({
    W Function()? loading,
    W Function(D data)? loaded,
    W Function(dynamic error, String message)? error,
    required W Function() orElse,
  }) {
    if (this is DataStateLoading) {
      return loading?.call() ?? orElse();
    } else if (this is DataStateLoaded) {
      return loaded?.call((this as DataStateLoaded<T, D>).data) ?? orElse();
    } else if (this is DataStateError) {
      return error?.call((this as DataStateError).error, (this as DataStateError).message) ??
          orElse();
    }
    return orElse();
  }
}

/// State representing a loading operation in the notifier.
class DataStateLoading<T, D> extends DataState<T, D> {
  /// Creates a loading state.
  const DataStateLoading() : super._();
}

/// State representing a successful data load in the notifier.
class DataStateLoaded<T, D> extends DataState<T, D> {
  /// The loaded data.
  final D data;

  /// Creates a loaded state with the given [data].
  const DataStateLoaded(this.data) : super._();
}

/// State representing an error in the notifier.
class DataStateError<T, D> extends DataState<T, D> {
  /// The error object.
  final dynamic error;

  /// The error message.
  final String message;

  /// Creates an error state with the given [error] and [message].
  const DataStateError(this.error, this.message) : super._();
}
