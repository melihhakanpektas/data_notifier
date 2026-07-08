import 'package:flutter/foundation.dart';

/// Base class representing the state of a [DataNotifier].
///
/// [D] is the type of the data being loaded.
///
/// This is a `sealed` class, so besides the [when]/[maybeWhen]/[whenOrElse]
/// helpers you can use Dart's native exhaustive pattern matching:
///
/// ```dart
/// final widget = switch (state) {
///   NotifierStateLoading() => const CircularProgressIndicator(),
///   NotifierStateLoaded(:final data) => Text('$data'),
///   NotifierStateError(:final message) => Text(message),
/// };
/// ```
@immutable
sealed class NotifierState<D> {
  const NotifierState();

  /// Whether this state is [NotifierStateLoading].
  bool get isLoading => this is NotifierStateLoading<D>;

  /// Whether this state is [NotifierStateLoaded].
  bool get isLoaded => this is NotifierStateLoaded<D>;

  /// Whether this state is [NotifierStateError].
  bool get isError => this is NotifierStateError<D>;

  /// The loaded data, or `null` if this state is not [NotifierStateLoaded].
  D? get dataOrNull => switch (this) {
    NotifierStateLoaded<D>(data: final d) => d,
    _ => null,
  };

  /// The loaded data if this state is [NotifierStateLoaded], otherwise the
  /// data from the last loaded state carried over into the current loading
  /// or error state ([NotifierStateLoading.previousData] /
  /// [NotifierStateError.previousData]), or `null` if no data has been
  /// loaded yet.
  ///
  /// Useful for showing stale data while a refresh is in progress.
  D? get dataOrPrevious => switch (this) {
    NotifierStateLoaded<D>(data: final d) => d,
    NotifierStateLoading<D>(previousData: final d) => d,
    NotifierStateError<D>(previousData: final d) => d,
  };

  /// Pattern matching for all state types.
  ///
  /// Requires a callback for each possible state.
  /// - [loading]: Called when the state is [NotifierStateLoading].
  /// - [loaded]: Called when the state is [NotifierStateLoaded], provides the loaded data.
  /// - [error]: Called when the state is [NotifierStateError], provides the error and message.
  W when<W>({
    required W Function() loading,
    required W Function(D data) loaded,
    required W Function(Object? error, String message) error,
  }) {
    return switch (this) {
      NotifierStateLoading<D>() => loading(),
      NotifierStateLoaded<D>(data: final d) => loaded(d),
      NotifierStateError<D>(error: final e, message: final m) => error(e, m),
    };
  }

  /// Pattern matching for state types, with optional callbacks.
  ///
  /// Returns the result of the matching callback. If the callback for the
  /// current state is not provided, [orElse] is called instead; if [orElse]
  /// is also not provided, returns `null`.
  /// - [loading]: Optional callback for [NotifierStateLoading].
  /// - [loaded]: Optional callback for [NotifierStateLoaded], provides the loaded data.
  /// - [error]: Optional callback for [NotifierStateError], provides the error and message.
  /// - [orElse]: Optional fallback callback used when the matching callback is not provided.
  W? maybeWhen<W>({
    W Function()? loading,
    W Function(D data)? loaded,
    W Function(Object? error, String message)? error,
    W Function()? orElse,
  }) {
    return switch (this) {
      NotifierStateLoading<D>() =>
        loading != null ? loading() : orElse?.call(),
      NotifierStateLoaded<D>(data: final d) =>
        loaded != null ? loaded(d) : orElse?.call(),
      NotifierStateError<D>(error: final e, message: final m) =>
        error != null ? error(e, m) : orElse?.call(),
    };
  }

  /// Pattern matching for state types, with a required fallback.
  ///
  /// Returns the result of the matching callback, or [orElse] if the callback
  /// for the current state is not provided.
  /// - [loading]: Optional callback for [NotifierStateLoading].
  /// - [loaded]: Optional callback for [NotifierStateLoaded], provides the loaded data.
  /// - [error]: Optional callback for [NotifierStateError], provides the error and message.
  /// - [orElse]: Required fallback callback used when the matching callback is not provided.
  W whenOrElse<W>({
    W Function()? loading,
    W Function(D data)? loaded,
    W Function(Object? error, String message)? error,
    required W Function() orElse,
  }) {
    return switch (this) {
      NotifierStateLoading<D>() => loading != null ? loading() : orElse(),
      NotifierStateLoaded<D>(data: final d) =>
        loaded != null ? loaded(d) : orElse(),
      NotifierStateError<D>(error: final e, message: final m) =>
        error != null ? error(e, m) : orElse(),
    };
  }
}

/// State representing a loading operation in the notifier.
class NotifierStateLoading<D> extends NotifierState<D> {
  /// The data from the last loaded state, if any.
  ///
  /// Allows the UI to keep showing stale data while a refresh is in
  /// progress. [DataNotifier.setLoading] and [DataNotifier.load] carry this
  /// over automatically.
  final D? previousData;

  /// Creates a loading state, optionally carrying [previousData] from the
  /// last loaded state.
  const NotifierStateLoading({this.previousData});

  @override
  bool operator ==(Object other) =>
      other is NotifierStateLoading<D> && other.previousData == previousData;

  @override
  int get hashCode => Object.hash(NotifierStateLoading<D>, previousData);

  @override
  String toString() => 'NotifierStateLoading<$D>()';
}

/// State representing a successful data load in the notifier.
class NotifierStateLoaded<D> extends NotifierState<D> {
  /// The loaded data.
  final D data;

  /// Creates a loaded state with the given [data].
  const NotifierStateLoaded(this.data);

  @override
  bool operator ==(Object other) =>
      other is NotifierStateLoaded<D> && other.data == data;

  @override
  int get hashCode => Object.hash(NotifierStateLoaded<D>, data);

  @override
  String toString() => 'NotifierStateLoaded<$D>($data)';
}

/// State representing an error in the notifier.
class NotifierStateError<D> extends NotifierState<D> {
  /// The error object.
  final Object? error;

  /// The error message.
  final String message;

  /// The stack trace at the time the error occurred, if available.
  final StackTrace? stackTrace;

  /// The data from the last loaded state, if any.
  ///
  /// Allows the UI to keep showing stale data alongside the error.
  /// [DataNotifier.setError] and [DataNotifier.load] carry this over
  /// automatically.
  final D? previousData;

  /// Creates an error state with the given [error] and [message], optionally
  /// carrying [previousData] from the last loaded state.
  const NotifierStateError(
    this.error,
    this.message, {
    this.stackTrace,
    this.previousData,
  });

  @override
  bool operator ==(Object other) =>
      other is NotifierStateError<D> &&
      other.error == error &&
      other.message == message &&
      other.stackTrace == stackTrace &&
      other.previousData == previousData;

  @override
  int get hashCode => Object.hash(
    NotifierStateError<D>,
    error,
    message,
    stackTrace,
    previousData,
  );

  @override
  String toString() => 'NotifierStateError<$D>($error, $message)';
}
