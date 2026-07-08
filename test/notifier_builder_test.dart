import 'package:data_notifier/data_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotifierBuilder', () {
    testWidgets('rebuilds when the value changes', (tester) async {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: NotifierBuilder<int>(
            valueNotifier: notifier,
            builder: (context, value, child) => Text('$value'),
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);

      notifier.value = 1;
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('calls onInit once with the initial value', (tester) async {
      final notifier = ValueNotifier<int>(5);
      addTearDown(notifier.dispose);
      final initValues = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: NotifierBuilder<int>(
            valueNotifier: notifier,
            onInit: initValues.add,
            builder: (context, value, child) => Text('$value'),
          ),
        ),
      );

      notifier.value = 6;
      await tester.pump();
      expect(initValues, [5]);
    });

    testWidgets('listener receives old and new values after the rebuild', (
      tester,
    ) async {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);
      final changes = <(int, int)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: NotifierBuilder<int>(
            valueNotifier: notifier,
            listener: (oldValue, newValue) => changes.add((oldValue, newValue)),
            builder: (context, value, child) => Text('$value'),
          ),
        ),
      );

      notifier.value = 1;
      await tester.pump();
      expect(changes, [(0, 1)]);

      notifier.value = 2;
      await tester.pump();
      expect(changes, [(0, 1), (1, 2)]);
    });

    testWidgets('listenWhen filters listener calls', (tester) async {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);
      final changes = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: NotifierBuilder<int>(
            valueNotifier: notifier,
            listenWhen: (previous, current) => current.isEven,
            listener: (oldValue, newValue) => changes.add(newValue),
            builder: (context, value, child) => Text('$value'),
          ),
        ),
      );

      notifier.value = 1;
      await tester.pump();
      notifier.value = 2;
      await tester.pump();
      expect(changes, [2]);
    });

    testWidgets('buildWhen filters rebuilds but not the listener', (
      tester,
    ) async {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);
      final listened = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: NotifierBuilder<int>(
            valueNotifier: notifier,
            buildWhen: (previous, current) => current.isEven,
            listener: (oldValue, newValue) => listened.add(newValue),
            builder: (context, value, child) => Text('$value'),
          ),
        ),
      );

      notifier.value = 1;
      await tester.pump();
      // Rebuild skipped, but the listener still fired.
      expect(find.text('0'), findsOneWidget);
      expect(listened, [1]);

      notifier.value = 2;
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      expect(listened, [1, 2]);
    });

    testWidgets('buildWhen compares against the latest value', (tester) async {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);
      final comparisons = <(int, int)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: NotifierBuilder<int>(
            valueNotifier: notifier,
            buildWhen: (previous, current) {
              comparisons.add((previous, current));
              return false;
            },
            builder: (context, value, child) => Text('$value'),
          ),
        ),
      );

      notifier.value = 1;
      await tester.pump();
      notifier.value = 2;
      await tester.pump();
      // Even though no rebuild happened, the second comparison starts from
      // the latest value (1), not the last built one (0).
      expect(comparisons, [(0, 1), (1, 2)]);
    });

    testWidgets('works as a pure listener with only a child', (tester) async {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);
      final changes = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: NotifierBuilder<int>(
            valueNotifier: notifier,
            listener: (oldValue, newValue) => changes.add(newValue),
            child: const Text('static'),
          ),
        ),
      );
      expect(find.text('static'), findsOneWidget);

      notifier.value = 1;
      await tester.pump();
      expect(changes, [1]);
      expect(find.text('static'), findsOneWidget);
    });

    testWidgets('resubscribes when the notifier instance changes', (
      tester,
    ) async {
      final first = ValueNotifier<int>(1);
      final second = ValueNotifier<int>(10);
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      Widget build(ValueNotifier<int> notifier) => MaterialApp(
        home: NotifierBuilder<int>(
          valueNotifier: notifier,
          builder: (context, value, child) => Text('$value'),
        ),
      );

      await tester.pumpWidget(build(first));
      expect(find.text('1'), findsOneWidget);

      await tester.pumpWidget(build(second));
      expect(find.text('10'), findsOneWidget);

      // The old notifier must no longer trigger rebuilds.
      first.value = 2;
      await tester.pump();
      expect(find.text('10'), findsOneWidget);

      second.value = 11;
      await tester.pump();
      expect(find.text('11'), findsOneWidget);
    });

    testWidgets('passes the child through to the builder', (tester) async {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: NotifierBuilder<int>(
            valueNotifier: notifier,
            builder: (context, value, child) =>
                Column(children: [Text('$value'), child!]),
            child: const Text('static child'),
          ),
        ),
      );
      expect(find.text('static child'), findsOneWidget);
    });

    test('asserts when neither builder nor child is provided', () {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);
      expect(
        () => NotifierBuilder<int>(valueNotifier: notifier),
        throwsAssertionError,
      );
    });

    testWidgets('works with DataNotifier states end to end', (tester) async {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      addTearDown(notifier.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: NotifierBuilder<NotifierState<int>>(
            valueNotifier: notifier,
            builder: (context, value, child) => switch (value) {
              NotifierStateLoading() => const Text('loading'),
              NotifierStateLoaded(:final data) => Text('loaded $data'),
              NotifierStateError(:final message) => Text('error $message'),
            },
          ),
        ),
      );
      expect(find.text('loading'), findsOneWidget);

      notifier.setLoaded(42);
      await tester.pump();
      expect(find.text('loaded 42'), findsOneWidget);

      notifier.setError(Exception('boom'), 'boom');
      await tester.pump();
      expect(find.text('error boom'), findsOneWidget);
    });
  });
}
