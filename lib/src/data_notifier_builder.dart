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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Signature for a function that builds a widget based on the given value.
typedef ValueWidgetBuilder<T> = Widget Function(BuildContext context, T value, Widget? child);

/// Signature for a function that listens to value changes.
typedef Listener<T> = void Function(T oldValue, T newValue);

/// A widget that rebuilds itself when the [valueNotifier] changes.
///
/// [NotifierBuilder] listens to a [ValueListenable] and calls the [builder]
/// whenever the value changes. Optionally, you can provide a [listener] to
/// react to value changes, and a [listenWhen] callback to perform an action
/// when the widget is initialized.
class NotifierBuilder<T> extends StatefulWidget {
  /// Creates a [NotifierBuilder].
  ///
  /// [valueNotifier] is required and must not be null.
  /// [builder] is called every time the value changes.
  /// [listener] is called with the old and new values when the value changes.
  /// [listenWhen] is called with the initial value in [initState].
  /// [child] is passed to the [builder] as an optimization.
  const NotifierBuilder({
    super.key,
    required this.valueNotifier,
    required this.builder,
    this.listener,
    this.listenWhen,
    this.child,
  });

  /// The [ValueListenable] to listen to.
  final ValueListenable<T> valueNotifier;

  /// Called every time the value changes.
  final ValueWidgetBuilder<T> builder;

  /// Optional callback called with the old and new values when the value changes.
  final Listener<T>? listener;

  /// Optional callback called with the initial value in [initState].
  final ValueChanged<T>? listenWhen;

  /// An optional child widget that does not depend on the value.
  final Widget? child;

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
    if (widget.listenWhen != null) {
      widget.listenWhen!(value);
    }
    widget.valueNotifier.addListener(_valueChanged);
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

  /// Called when the value changes.
  void _valueChanged() {
    setState(() {
      final T oldValue = value;
      value = widget.valueNotifier.value;
      widget.listener?.call(oldValue, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}
