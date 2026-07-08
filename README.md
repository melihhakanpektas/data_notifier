# data_notifier

`data_notifier` is a lightweight Flutter package for managing and observing data states using nothing but Flutter's native `ValueNotifier` and `ValueListenable`. It provides a structured way to handle loading, loaded, and error states in your applications — with no code generation, no context magic, and a near-zero learning curve — plus enhanced debugging through colorful console output.

## Features

- **NotifierState**: A `sealed` class representing loading, loaded, and error states — works with Dart's native exhaustive `switch` pattern matching.
- **DataNotifier**: Extends `ValueNotifier` with convenient state setters and debug output.
- **NotifierBuilder**: A drop-in `ValueListenableBuilder` replacement with listener support.
- **Colorful Console Output**: In debug mode, prints colored messages to the console for each state change.

## Overview

### NotifierState

`NotifierState<D>` is a sealed class with three implementations, where `D` is the type of the data being loaded (a list, a model, or any other type):

- **`NotifierStateLoading<D>`**: Represents a loading state.
  - `previousData`: Optional data carried over from the last loaded state, so the UI can keep showing stale data while a refresh is in progress.
- **`NotifierStateLoaded<D>`**: Represents successfully loaded data.
  - `data`: The loaded data of type `D`.
- **`NotifierStateError<D>`**: Represents an error state.
  - `error`: The error object (`Object?`).
  - `message`: The error message (`String`).
  - `stackTrace`: Optional `StackTrace` captured when the error occurred.
  - `previousData`: Optional data carried over from the last loaded state.

All states implement `==` and `hashCode`, so setting an equal state does not trigger unnecessary rebuilds.

#### State Checking and Pattern Matching

Because `NotifierState` is sealed, the most native way to handle states is a plain `switch` — the compiler guarantees you covered every case:

```dart
final widget = switch (state) {
  NotifierStateLoading() => const CircularProgressIndicator(),
  NotifierStateLoaded(:final data) => Text('$data'),
  NotifierStateError(:final message) => Text('Error: $message'),
};
```

If you prefer callback-style matching, the following helpers are available:

- `when`: Requires callbacks for all states (loading, loaded, error) for exhaustive matching.
- `maybeWhen`: Provide callbacks only for the states you care about; `orElse` (or `null`) is used for the rest.
- `whenOrElse`: Like `maybeWhen`, but with a required `orElse` fallback.

```dart
state.when(
  loading: () => print('Loading...'),
  loaded: (data) => print('Data loaded: $data'),
  error: (error, message) => print('Error: $message'),
);
```

Quick checks are also available: `state.isLoading`, `state.isLoaded`, `state.isError`, `state.dataOrNull`, and `state.dataOrPrevious` (the loaded data, falling back to the data carried over into a loading/error state).

### DataNotifier

`DataNotifier<D>` is a `ValueNotifier<NotifierState<D>>` with an async `load` helper and convenience setters:

```dart
class CounterNotifier extends DataNotifier<int> {
  CounterNotifier() : super.loading() {
    load(fetchCounter, errorMessage: 'Failed to load counter');
  }

  void refresh() => load(fetchCounter);

  void increment() {
    final data = value.dataOrNull;
    if (data != null) setLoaded(data + 1);
  }
}
```

`load` sets the state to loading, awaits the fetch, and then sets a loaded state with the result — or an error state (with the stack trace) if the fetch throws. It is safe by default:

- **Latest call wins:** if `load` is called again before a previous call completes, the stale result is discarded.
- **Dispose-safe:** if the notifier is disposed while the fetch is in flight, the result is discarded instead of throwing.
- **Keeps stale data:** the current data is carried into the loading state as `previousData`, so the UI can show it during a refresh (`value.dataOrPrevious`).

The same data preservation applies to `setLoading()` and `setError(...)`; pass `preserveData: false` to discard it.

In debug mode, every state change is printed to the console with a color matching the state (yellow for loading, green for loaded, red for error). Disable this with `debugConsoleLogs: false`, or customize the log prefix with `debugLabel`.

### NotifierBuilder

The `NotifierBuilder<T>` widget is a reactive widget that works with any `ValueListenable<T>` (e.g., `ValueNotifier`, `DataNotifier`, etc.).

#### Differences from ValueListenableBuilder

- **Listener Support:** Define a `listener` that receives the old and new values when the value changes — for side effects such as navigation or snackbars, not just rebuilds.
- **listenWhen:** Control when the `listener` fires. Called with the previous and current values on every change; the listener only runs when it returns `true`.
- **buildWhen:** Control when the widget rebuilds. Called with the previous and current values on every change; the rebuild is skipped when it returns `false` (the `listener` is unaffected).
- **onInit:** Called once with the current value when the widget is first created.
- **Pure Listener Mode:** Omit `builder` and provide only `child` to react to changes without ever rebuilding.
- **Child Widget Optimization:** The `child` parameter lets you cache sub-widgets that do not depend on the value.

#### Basic Usage

```dart
NotifierBuilder<NotifierState<int>>(
  valueNotifier: myNotifier,
  builder: (context, value, child) => switch (value) {
    NotifierStateLoading() => const CircularProgressIndicator(),
    NotifierStateLoaded(:final data) => Text('$data'),
    NotifierStateError(:final message) => Text('Error: $message'),
  },
  listener: (oldValue, newValue) {
    if (newValue.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  },
  listenWhen: (previous, current) => previous != current,
  onInit: (value) => print('Initial value: $value'),
)
```

> **Note:** The `listener` is called after the frame completes. Do not call `setState` or trigger rebuilds inside it.

#### Listening to Multiple Notifiers

No extra API is needed to combine notifiers — Flutter's native `Listenable.merge` works with any `ValueListenable`, including `DataNotifier`. Wrap the merge in a `ListenableBuilder` and read the notifiers directly:

```dart
ListenableBuilder(
  listenable: Listenable.merge([userNotifier, ordersNotifier]),
  builder: (context, child) {
    if (userNotifier.value.isLoading || ordersNotifier.value.isLoading) {
      return const CircularProgressIndicator();
    }
    return OrdersView(
      user: userNotifier.value.dataOrNull,
      orders: ordersNotifier.value.dataOrNull,
    );
  },
)
```

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  data_notifier: ^0.2.0
```

## Migrating from 0.1.x

- `NotifierState<T, D>` → `NotifierState<D>` (the notifier type parameter was removed; use `debugLabel` on `DataNotifier` for log naming).
- `DataNotifier<NotifierState<T, D>>` → `DataNotifier<D>`.
- `when`'s `error` callback now receives `(Object? error, String message)`.
- `maybeWhen` now calls `orElse` when the callback for the current state is missing.
- The `Listener` typedef is now `NotifierListener`; `ListenWhen` is now `NotifierListenWhen`.

## Usage

See the example directory for a complete usage example.

---
