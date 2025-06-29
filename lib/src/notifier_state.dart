// Copyright 2025 Melih Hakan Pektas
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Base class representing the state of a notifier.
///
/// [T] is the type of the notifier, [D] is the type of the data.
/// This class is intended to be extended by specific state implementations
/// such as [NotifierStateLoading], [NotifierStateLoaded], and [NotifierStateError].
abstract class NotifierState<T, D> {
  /// Private constructor to prevent direct instantiation.
  const NotifierState._();

  /// Pattern matching for all state types.
  ///
  /// Requires a callback for each possible state.
  /// - [loading]: Called when the state is [NotifierStateLoading].
  /// - [loaded]: Called when the state is [NotifierStateLoaded], provides the loaded data.
  /// - [error]: Called when the state is [NotifierStateError], provides the error message.
  W when<W>({
    required W Function() loading,
    required W Function(D data) loaded,
    required W Function(String message) error,
  }) {
    if (this is NotifierStateLoading) {
      return loading();
    } else if (this is NotifierStateLoaded) {
      return loaded.call((this as NotifierStateLoaded<T, D>).data);
    } else if (this is NotifierStateError) {
      return error((this as NotifierStateError).message);
    } else {
      throw Exception("Unknown state: $this");
    }
  }

  /// Pattern matching for state types, with optional callbacks.
  ///
  /// Returns the result of the matching callback, or [orElse] if provided and no match is found.
  /// - [loading]: Optional callback for [NotifierStateLoading].
  /// - [loaded]: Optional callback for [NotifierStateLoaded], provides the loaded data.
  /// - [error]: Optional callback for [NotifierStateError], provides the error and message.
  /// - [orElse]: Optional fallback callback if no match is found.
  W? maybeWhen<W>({
    W Function()? loading,
    W Function(D data)? loaded,
    W Function(dynamic error, String message)? error,
    W Function()? orElse,
  }) {
    if (this is NotifierStateLoading) {
      return loading?.call();
    } else if (this is NotifierStateLoaded) {
      return loaded?.call((this as NotifierStateLoaded<T, D>).data);
    } else if (this is NotifierStateError) {
      return error?.call((this as NotifierStateError).error, (this as NotifierStateError).message);
    }
    return orElse?.call();
  }

  /// Pattern matching for state types, with a required fallback.
  ///
  /// Returns the result of the matching callback, or [orElse] if no match is found.
  /// - [loading]: Optional callback for [NotifierStateLoading].
  /// - [loaded]: Optional callback for [NotifierStateLoaded], provides the loaded data.
  /// - [error]: Optional callback for [NotifierStateError], provides the error and message.
  /// - [orElse]: Required fallback callback if no match is found.
  W whenOrElse<W>({
    W Function()? loading,
    W Function(D data)? loaded,
    W Function(dynamic error, String message)? error,
    required W Function() orElse,
  }) {
    if (this is NotifierStateLoading) {
      return loading?.call() ?? orElse();
    } else if (this is NotifierStateLoaded) {
      return loaded?.call((this as NotifierStateLoaded<T, D>).data) ?? orElse();
    } else if (this is NotifierStateError) {
      return error?.call(
            (this as NotifierStateError).error,
            (this as NotifierStateError).message,
          ) ??
          orElse();
    }
    return orElse();
  }
}

/// State representing a loading operation in the notifier.
class NotifierStateLoading<T, D> extends NotifierState<T, D> {
  /// Creates a loading state.
  const NotifierStateLoading() : super._();
}

/// State representing a successful data load in the notifier.
class NotifierStateLoaded<T, D> extends NotifierState<T, D> {
  /// The loaded data.
  final D data;

  /// Creates a loaded state with the given [data].
  const NotifierStateLoaded(this.data) : super._();
}

/// State representing an error in the notifier.
class NotifierStateError<T, D> extends NotifierState<T, D> {
  /// The error object.
  final dynamic error;

  /// The error message.
  final String message;

  /// Creates an error state with the given [error] and [message].
  const NotifierStateError(this.error, this.message) : super._();
}
