# data_notifier

`data_notifier` is a Flutter package for managing and observing data changes on server in a reactive and simple way.

## Features

- **NotifierState**: Represents loading, loaded, and error states for your data.
- **DataNotifier**: Extends `ValueNotifier` to provide state management and debug output.
- **Colorful Console Output**: In debug mode, prints colored and styled messages to the console for different states.

## File Overview

### lib/src/notifier_state.dart

Defines the `NotifierState<T, D>` abstract class and its implementations:

- `NotifierStateLoading`, `NotifierStateLoaded`, `NotifierStateError`: Represent loading, loaded, and error states.
- Provides `when`, `maybeWhen`, and `whenOrElse` methods for easy state handling.

### lib/src/data_notifier.dart

- `DataNotifier<T extends NotifierState>`: A custom `ValueNotifier` that listens to state changes and prints debug information with color.
- Ensures UI updates are triggered at the right time.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  data_notifier: latest
```

## Usage

See the example directory for a complete usage example.

---
