import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that listens to value changes.
typedef NotifierListener<T> = void Function(T oldValue, T newValue);

/// Signature for a function that determines whether to call the listener.
///
/// Called on every value change. If it returns `true`, the listener will be
/// triggered; if it returns `false`, the listener will not be called.
typedef NotifierListenWhen<T> = bool Function(T previous, T current);

/// Signature for a function that determines whether to rebuild the widget.
///
/// Called on every value change. If it returns `true`, the builder will be
/// called with the new value; if it returns `false`, the rebuild is skipped.
typedef NotifierBuildWhen<T> = bool Function(T previous, T current);

/// A widget that rebuilds itself when the [valueNotifier] changes.
///
/// [NotifierBuilder] listens to a [ValueListenable] and calls the [builder]
/// whenever the value changes. Optionally, you can provide a [listener] to
/// react to value changes, and a [listenWhen] callback to control when the
/// [listener] should be triggered.
///
/// The [builder] uses Flutter's own [ValueWidgetBuilder] signature, so it is
/// a drop-in replacement for [ValueListenableBuilder].
///
/// **WARNING:**
/// Do **NOT** call `setState` or trigger a rebuild inside the [listener]
/// callback! Doing so may cause unexpected rebuilds and infinite loops.
/// The [listener] is called after the widget has rebuilt, so any further
/// rebuilds triggered from within the [listener] can lead to unstable
/// widget behavior.
class NotifierBuilder<T> extends StatefulWidget {
  /// Creates a [NotifierBuilder].
  ///
  /// Either [builder] or [child] must be provided; providing only [child]
  /// turns the widget into a pure listener that never rebuilds.
  const NotifierBuilder({
    super.key,
    required this.valueNotifier,
    this.builder,
    this.buildWhen,
    this.listener,
    this.listenWhen,
    this.child,
    this.onInit,
  }) : assert(
         builder != null || child != null,
         'Either builder or child must be provided to NotifierBuilder.',
       );

  /// The [ValueListenable] to listen to.
  final ValueListenable<T> valueNotifier;

  /// Called every time the value changes.
  final ValueWidgetBuilder<T>? builder;

  /// Optional callback that determines whether to rebuild when the value
  /// changes. Called with the previous and current values; the rebuild is
  /// skipped when it returns `false`.
  ///
  /// Note that a skipped value may still become visible if the widget
  /// rebuilds for another reason (e.g. a parent rebuild), and the next
  /// [buildWhen] call always compares against the latest value.
  final NotifierBuildWhen<T>? buildWhen;

  /// Optional callback called with the old and new values when the value changes.
  /// Will only be called if [listenWhen] returns true (or if [listenWhen] is not provided).
  final NotifierListener<T>? listener;

  /// Optional callback that determines whether to call the [listener].
  /// Called on every value change with the previous and current values.
  final NotifierListenWhen<T>? listenWhen;

  /// An optional child widget that does not depend on the value.
  final Widget? child;

  /// Optional callback that is called once with the current value when the
  /// widget is initialized.
  final void Function(T value)? onInit;

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
    final shouldRebuild =
        widget.builder != null &&
        (widget.buildWhen?.call(oldValue, newValue) ?? true);
    if (shouldRebuild) {
      setState(() {
        value = newValue;
      });
    } else {
      // Nothing depends on the value visually (no builder, or buildWhen
      // returned false); skip the rebuild and only track the value.
      value = newValue;
    }
    if (widget.listener != null &&
        (widget.listenWhen?.call(oldValue, newValue) ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.listener?.call(oldValue, newValue);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder?.call(context, value, widget.child) ?? widget.child!;
  }
}
