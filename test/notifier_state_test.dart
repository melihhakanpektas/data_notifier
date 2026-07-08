import 'package:data_notifier/data_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotifierState convenience getters', () {
    test('isLoading / isLoaded / isError', () {
      expect(const NotifierStateLoading<int>().isLoading, isTrue);
      expect(const NotifierStateLoading<int>().isLoaded, isFalse);
      expect(const NotifierStateLoaded<int>(1).isLoaded, isTrue);
      expect(const NotifierStateLoaded<int>(1).isError, isFalse);
      expect(const NotifierStateError<int>(null, 'oops').isError, isTrue);
      expect(const NotifierStateError<int>(null, 'oops').isLoading, isFalse);
    });

    test('dataOrNull returns data only when loaded', () {
      expect(const NotifierStateLoaded<int>(42).dataOrNull, 42);
      expect(const NotifierStateLoading<int>().dataOrNull, isNull);
      expect(const NotifierStateError<int>(null, 'oops').dataOrNull, isNull);
      expect(
        const NotifierStateLoading<int>(previousData: 42).dataOrNull,
        isNull,
      );
    });

    test('dataOrPrevious falls back to previousData', () {
      expect(const NotifierStateLoaded<int>(42).dataOrPrevious, 42);
      expect(
        const NotifierStateLoading<int>(previousData: 42).dataOrPrevious,
        42,
      );
      expect(
        const NotifierStateError<int>(null, 'oops', previousData: 42)
            .dataOrPrevious,
        42,
      );
      expect(const NotifierStateLoading<int>().dataOrPrevious, isNull);
      expect(const NotifierStateError<int>(null, 'oops').dataOrPrevious, isNull);
    });
  });

  group('when', () {
    test('dispatches to the matching callback', () {
      String describe(NotifierState<int> state) => state.when(
        loading: () => 'loading',
        loaded: (data) => 'loaded $data',
        error: (error, message) => 'error $message',
      );

      expect(describe(const NotifierStateLoading()), 'loading');
      expect(describe(const NotifierStateLoaded(7)), 'loaded 7');
      expect(describe(const NotifierStateError(null, 'boom')), 'error boom');
    });

    test('error callback receives the error object', () {
      final exception = Exception('boom');
      final state = NotifierStateError<int>(exception, 'boom');
      final received = state.when(
        loading: () => null,
        loaded: (_) => null,
        error: (error, message) => error,
      );
      expect(received, same(exception));
    });
  });

  group('maybeWhen', () {
    test('calls the matching callback when provided', () {
      expect(
        const NotifierStateLoaded<int>(3).maybeWhen(loaded: (data) => data),
        3,
      );
    });

    test('falls back to orElse when the matching callback is missing', () {
      expect(
        const NotifierStateLoading<int>().maybeWhen(
          loaded: (data) => 'loaded',
          orElse: () => 'fallback',
        ),
        'fallback',
      );
      expect(
        const NotifierStateError<int>(null, 'boom').maybeWhen(
          loading: () => 'loading',
          orElse: () => 'fallback',
        ),
        'fallback',
      );
    });

    test('returns null when neither matching callback nor orElse is given', () {
      expect(
        const NotifierStateLoading<int>().maybeWhen(loaded: (data) => data),
        isNull,
      );
    });
  });

  group('whenOrElse', () {
    test('calls the matching callback when provided', () {
      expect(
        const NotifierStateError<int>(null, 'boom').whenOrElse(
          error: (error, message) => message,
          orElse: () => 'fallback',
        ),
        'boom',
      );
    });

    test('falls back to orElse when the matching callback is missing', () {
      expect(
        const NotifierStateLoaded<int>(3).whenOrElse(
          loading: () => 'loading',
          orElse: () => 'fallback',
        ),
        'fallback',
      );
    });

    test('a matching callback that returns null does not trigger orElse', () {
      expect(
        const NotifierStateLoaded<int?>(null).whenOrElse<int?>(
          loaded: (data) => data,
          orElse: () => -1,
        ),
        isNull,
      );
    });
  });

  group('native sealed-class pattern matching', () {
    test('switch expression is exhaustive over the three states', () {
      String describe(NotifierState<int> state) => switch (state) {
        NotifierStateLoading() => 'loading',
        NotifierStateLoaded(:final data) => 'loaded $data',
        NotifierStateError(:final message) => 'error $message',
      };

      expect(describe(const NotifierStateLoading()), 'loading');
      expect(describe(const NotifierStateLoaded(1)), 'loaded 1');
      expect(describe(const NotifierStateError(null, 'x')), 'error x');
    });
  });

  group('equality', () {
    test('loading states of the same data type are equal', () {
      expect(const NotifierStateLoading<int>(), const NotifierStateLoading<int>());
      expect(
        const NotifierStateLoading<int>().hashCode,
        const NotifierStateLoading<int>().hashCode,
      );
    });

    test('loaded states are equal when data is equal', () {
      expect(NotifierStateLoaded<int>(5), NotifierStateLoaded<int>(5));
      expect(
        NotifierStateLoaded<int>(5).hashCode,
        NotifierStateLoaded<int>(5).hashCode,
      );
      expect(NotifierStateLoaded<int>(5), isNot(NotifierStateLoaded<int>(6)));
    });

    test('states with different previousData are not equal', () {
      expect(
        const NotifierStateLoading<int>(previousData: 1),
        const NotifierStateLoading<int>(previousData: 1),
      );
      expect(
        const NotifierStateLoading<int>(previousData: 1),
        isNot(const NotifierStateLoading<int>()),
      );
      expect(
        const NotifierStateError<int>(null, 'e', previousData: 1),
        isNot(const NotifierStateError<int>(null, 'e')),
      );
    });

    test('error states compare error, message, and stackTrace', () {
      const a = NotifierStateError<int>('e', 'msg');
      const b = NotifierStateError<int>('e', 'msg');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const NotifierStateError<int>('e', 'other')));
    });

    test('different state types are never equal', () {
      expect(
        const NotifierStateLoading<int>(),
        isNot(const NotifierStateLoaded<int>(0)),
      );
    });
  });
}
