import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Signature for a function that builds a widget based on the given value.
typedef ValueWidgetBuilder<T> = Widget Function(BuildContext context, T value, Widget? child);

/// Signature for a function that listens to value changes.
typedef Listener<T> = void Function(T oldValue, T newValue);

/// Signature for a function that determines whether to call the listener.
///
/// Called on every value change. If it returns `true`, the [listener] will be triggered.
/// If it returns `false`, the [listener] will not be called.
typedef ListenWhen<T> = bool Function(T previous, T current);

/// A widget that rebuilds itself when the [valueNotifier] changes.
///
/// [NotifierBuilder] listens to a [ValueListenable] and calls the [builder]
/// whenever the value changes. Optionally, you can provide a [listener] to
/// react to value changes, and a [listenWhen] callback to control when the
/// [listener] should be triggered.
///
/// **WARNING:**
/// Do **NOT** call `setState` or trigger a rebuild inside the [listener] callback!
/// Doing so may cause unexpected rebuilds and infinite loops.
/// The [listener] is called after the widget has rebuilt, so any further rebuilds
/// triggered from within the [listener] can lead to unstable widget behavior.
class NotifierBuilder<T> extends StatefulWidget {
  /// Creates a [NotifierBuilder].
  ///
  /// [valueNotifier] is required and must not be null.
  /// [builder] is called every time the value changes.
  /// [listener] is called with the old and new values when the value changes,
  /// if [listenWhen] returns true.
  /// [listenWhen] is called on every value change to determine whether to call [listener].
  /// [child] is passed to the [builder] as an optimization.
  const NotifierBuilder({
    super.key,
    required this.valueNotifier,
    required this.builder,
    this.listener,
    this.listenWhen,
    this.child,
    this.onInit,
  });

  /// The [ValueListenable] to listen to.
  final ValueListenable<T> valueNotifier;

  /// Called every time the value changes.
  final ValueWidgetBuilder<T> builder;

  /// Optional callback called with the old and new values when the value changes.
  /// Will only be called if [listenWhen] returns true (or if [listenWhen] is not provided).
  final Listener<T>? listener;

  /// Optional callback that determines whether to call the listener.
  /// Called on every value change with the previous and current values.
  final ListenWhen<T>? listenWhen;

  /// An optional child widget that does not depend on the value.
  final Widget? child;

  /// Optional callback that is called when the widget is initialized.
  final void Function(T)? onInit;

  @override
  State<StatefulWidget> createState() => _NotifierBuilderState<T>();
}

/// State for [NotifierBuilder].
class _NotifierBuilderState<T> extends State<NotifierBuilder<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.valueNotifier.value;
    widget.valueNotifier.addListener(_valueChanged);
    widget.onInit?.call(value);
  }

  @override
  void didUpdateWidget(NotifierBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueNotifier != widget.valueNotifier) {
      oldWidget.valueNotifier.removeListener(_valueChanged);
      value = widget.valueNotifier.value;
      widget.valueNotifier.addListener(_valueChanged);
    }
  }

  @override
  void dispose() {
    widget.valueNotifier.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged() {
    if (!mounted) return;
    final T oldValue = value;
    final T newValue = widget.valueNotifier.value;
    final shouldCallListener = widget.listenWhen?.call(oldValue, newValue) ?? true;
    setState(() {
      value = newValue;
    });
    if (shouldCallListener && widget.listener != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.listener?.call(oldValue, newValue);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}
