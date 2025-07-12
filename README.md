# data_notifier

`data_notifier` is a Flutter package for managing and observing data states using `ValueNotifier` and `ValueListenable`. It provides a structured way to handle loading, loaded, and error states in your applications, with enhanced debugging capabilities through colorful console output.

## Features

- **NotifierState**: Represents loading, loaded, and error states for your data.
- **DataNotifier**: Extends `ValueNotifier` to provide state management and debug output.
- **Colorful Console Output**: In debug mode, prints colored and styled messages to the console for different states.

## Overview

### NotifierState

Defines the `NotifierState<T, D>` abstract class and its implementations:

- `NotifierStateLoading`, `NotifierStateLoaded`, `NotifierStateError`: Represent loading, loaded, and error states.
- Provides `when`, `maybeWhen`, and `whenOrElse` methods for easy state handling.

#### NotifierState Type Parameters

- **T**: The type of the notifier itself or the context to which the state belongs. Typically used to indicate what kind of notifier you are working with.
- **D**: The type of the data being loaded. For example, this can be a list, a model, or any data type.

#### State Classes and Parameters

- **NotifierStateLoading<T, D>**: Represents a loading state. Takes no parameters.
- **NotifierStateLoaded<T, D>**: Represents a successfully loaded data state.
  - `data`: Contains the loaded data. Type is `D`.
- **NotifierStateError<T, D>**: Represents an error state.
  - `error`: The error object (can be any type).
  - `message`: The error message (String).

#### State Checking and Pattern Matching

You can easily handle states using the following methods:

- `when`: Requires callbacks for all states (loading, loaded, error) for exhaustive pattern matching.
- `maybeWhen`: Allows you to provide callbacks only for the states you care about; returns null or calls `orElse` for others.
- `whenOrElse`: Like `maybeWhen`, but requires an `orElse` fallback callback for unmatched states.

Example usage:

```dart
state.when(
  loading: () => print('Loading...'),
  loaded: (data) => print('Data loaded: $data'),
  error: (message) => print('Error: $message'),
);
```

### DataNotifier

- `DataNotifier<T extends NotifierState>`: A custom `ValueNotifier` that listens to state changes and prints debug information with color.
- Ensures UI updates are triggered at the right time.

### NotifierBuilder

The `NotifierBuilder<T>` widget is a reactive widget that can work with any `ValueListenable<T>` (e.g., `ValueNotifier`, `DataNotifier`, etc.).

#### Differences from ValueListenableBuilder

- **Listener Support:** `NotifierBuilder` allows you to define a `listener` function that receives both the old and new values when the value changes. This enables you to perform side effects or additional actions, not just rebuild the widget.
- **listenWhen for Initial Value:** You can define a `listenWhen` function that is called once with the current value when the widget is first created (`initState`).
- **Works with Any ValueListenable:** Can be used with any `ValueListenable`, not just `ValueNotifier`.
- **Child Widget Optimization:** The `child` parameter allows you to optimize sub-widgets that do not depend on the value.

#### Basic Usage

```dart
NotifierBuilder<MyState>(
  valueNotifier: myNotifier,
  builder: (context, value, child) => Text('$value'),
  listener: (oldValue, newValue) {
    print('Value changed: $oldValue -> $newValue');
  },
  listenWhen: (initialValue) {
    print('Initial value: $initialValue');
  },
  child: const Icon(Icons.info),
)
```

> `NotifierBuilder` is especially more flexible and functional than the standard `ValueListenableBuilder` in cases where you need both widget updates and side effects.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  data_notifier: latest
```

## Usage

See the example directory for a complete usage example.

---
