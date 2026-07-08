import 'dart:async';

import 'package:data_notifier/data_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataNotifier', () {
    test('DataNotifier.loading starts in the loading state', () {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      expect(notifier.value, const NotifierStateLoading<int>());
      notifier.dispose();
    });

    test('setLoading / setLoaded / setError update the value', () {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);

      notifier.setLoaded(3);
      expect(notifier.value, const NotifierStateLoaded<int>(3));

      notifier.setError('e', 'boom');
      expect(
        notifier.value,
        const NotifierStateError<int>('e', 'boom', previousData: 3),
      );

      notifier.setLoading();
      expect(notifier.value, const NotifierStateLoading<int>(previousData: 3));

      notifier.dispose();
    });

    test('notifies listeners on state change', () {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      var notifications = 0;
      notifier.addListener(() => notifications++);

      notifier.setLoaded(1);
      notifier.setLoaded(2);
      expect(notifications, 2);

      notifier.dispose();
    });

    test('does not notify when the new state is equal to the old one', () {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      notifier.setLoaded(1);

      var notifications = 0;
      notifier.addListener(() => notifications++);
      notifier.setLoaded(1);
      expect(notifications, 0);

      notifier.dispose();
    });

    test('dispose with debug logging enabled does not throw', () {
      final notifier = DataNotifier<int>.loading();
      notifier.setLoaded(1);
      expect(notifier.dispose, returnsNormally);
      expect(notifier.isDisposed, isTrue);
    });

    test('setLoading and setError carry over the previous data', () {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      notifier.setLoaded(7);

      notifier.setLoading();
      expect(notifier.value, const NotifierStateLoading<int>(previousData: 7));
      expect(notifier.value.dataOrPrevious, 7);
      expect(notifier.value.dataOrNull, isNull);

      notifier.setError('e', 'boom');
      expect(notifier.value.dataOrPrevious, 7);

      // Data survives a full loading -> error -> loading round trip.
      notifier.setLoading();
      expect(notifier.value.dataOrPrevious, 7);

      notifier.dispose();
    });

    test('preserveData: false discards the previous data', () {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      notifier.setLoaded(7);

      notifier.setLoading(preserveData: false);
      expect(notifier.value, const NotifierStateLoading<int>());
      expect(notifier.value.dataOrPrevious, isNull);

      notifier.setLoaded(8);
      notifier.setError('e', 'boom', preserveData: false);
      expect(notifier.value.dataOrPrevious, isNull);

      notifier.dispose();
    });
  });

  group('DataNotifier.load', () {
    test('emits loading and then loaded on success', () async {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      notifier.setLoaded(1);
      final states = <NotifierState<int>>[];
      notifier.addListener(() => states.add(notifier.value));

      await notifier.load(() async => 42);

      expect(states, const [
        NotifierStateLoading<int>(previousData: 1),
        NotifierStateLoaded<int>(42),
      ]);
      notifier.dispose();
    });

    test('emits an error state when fetch throws', () async {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      final exception = Exception('boom');

      await notifier.load(() async => throw exception);

      final state = notifier.value;
      expect(state, isA<NotifierStateError<int>>());
      state as NotifierStateError<int>;
      expect(state.error, same(exception));
      expect(state.message, '$exception');
      expect(state.stackTrace, isNotNull);
      notifier.dispose();
    });

    test('errorMessage overrides the default message', () async {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);

      await notifier.load(
        () async => throw Exception('boom'),
        errorMessage: 'Failed to load counter',
      );

      expect(
        (notifier.value as NotifierStateError<int>).message,
        'Failed to load counter',
      );
      notifier.dispose();
    });

    test('carries previous data through the loading state', () async {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      notifier.setLoaded(1);

      final seen = <int?>[];
      notifier.addListener(() => seen.add(notifier.value.dataOrPrevious));
      await notifier.load(() async => 2);

      expect(seen, [1, 2]);
      notifier.dispose();
    });

    test('latest call wins when loads overlap', () async {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      final slow = Completer<int>();
      final fast = Completer<int>();

      final slowLoad = notifier.load(() => slow.future);
      final fastLoad = notifier.load(() => fast.future);

      fast.complete(2);
      await fastLoad;
      expect(notifier.value, const NotifierStateLoaded<int>(2));

      // The stale result must not overwrite the newer one.
      slow.complete(1);
      await slowLoad;
      expect(notifier.value, const NotifierStateLoaded<int>(2));

      notifier.dispose();
    });

    test('discards the result when disposed mid-flight', () async {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      final completer = Completer<int>();

      final pending = notifier.load(() => completer.future);
      notifier.dispose();

      completer.complete(1);
      await expectLater(pending, completes);
    });

    test('discards the error when disposed mid-flight', () async {
      final notifier = DataNotifier<int>.loading(debugConsoleLogs: false);
      final completer = Completer<int>();

      final pending = notifier.load(() => completer.future);
      notifier.dispose();

      completer.completeError(Exception('boom'));
      await expectLater(pending, completes);
    });
  });
}
