## 0.1.0

- Initial release.

## 0.1.3

- Readme and pubspec updates.

## 0.1.4

- Refactor notifier state management: rename NotifierState to NotifierState and update related classes and imports

## 0.1.5

- PrintColor enum added and cmd_color.dart removed; updated imports in data_notifier.dart and utils.dart
- Updated NotifierBuilder to be usable without a builder, allowing it to be used as just a listener.

## 0.1.6

- Refactor state management: rename DataState to NotifierState, update related classes and imports; remove unused DataState and DataNotifierBuilder files; enhance NotifierBuilder functionality.

## 0.2.0

**Breaking changes:**

- `NotifierState` is now a `sealed` class and its notifier type parameter `T` has been removed: `NotifierState<T, D>` is now `NotifierState<D>`. You can now use Dart's native exhaustive `switch` pattern matching on states.
- `DataNotifier` is now generic over the data type instead of the state type: `DataNotifier<NotifierState<T, D>>` is now `DataNotifier<D>` (always holding a `NotifierState<D>`).
- The `error` callback of `when` now receives `(Object? error, String message)` instead of `(String message)`, consistent with `maybeWhen`/`whenOrElse`.
- `maybeWhen` now calls `orElse` when the callback for the current state is not provided (previously `orElse` was unreachable and `null` was returned instead).
- The `Listener` and `ValueWidgetBuilder` typedefs no longer conflict with Flutter's own declarations: `Listener` was renamed to `NotifierListener`, `ListenWhen` to `NotifierListenWhen`, and `NotifierBuilder.builder` now uses Flutter's `ValueWidgetBuilder`.
- Removed the no-op `DataNotifier.cancel()` method.
- `NotifierStateError.error` is now typed as `Object?` instead of `dynamic`.

**New features:**

- `NotifierState` gained `isLoading`, `isLoaded`, `isError`, and `dataOrNull` convenience getters.
- `NotifierStateError` gained an optional `stackTrace` field.
- All states now implement `==` and `hashCode`, so setting an equal state no longer triggers unnecessary notifications/rebuilds.
- `DataNotifier` gained `setLoading()`, `setLoaded(data)`, and `setError(error, message, {stackTrace})` convenience setters, a `DataNotifier.loading()` constructor, and an optional `debugLabel` for console logs.
- `NotifierBuilder` now validates `builder`/`child` with a constructor assert (instead of throwing at build time) and skips rebuilds entirely when used as a pure listener without a `builder`.
- `DataNotifier` gained an async `load(fetch)` helper that emits loading and then loaded/error automatically. It is race-safe (when calls overlap, the latest call wins) and dispose-safe (results arriving after `dispose()` are discarded). An `isDisposed` getter was also added.
- Stale data is now preserved during reloads: `setLoading()`, `setError(...)`, and `load(...)` carry the current data into the new state as `previousData` (opt out with `preserveData: false`), and `NotifierState.dataOrPrevious` exposes it alongside `dataOrNull`.
- `NotifierBuilder` gained a `buildWhen` callback to filter rebuilds, symmetric to `listenWhen` (which only filters the `listener`).
- Added a comprehensive test suite.
