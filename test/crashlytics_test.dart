import 'package:test/test.dart';
import 'package:game1/src/crashlytics/crashlytics.dart';

void main() {
  group('filterStackTrace', () {
    test('keeps current stacktrace intact', () {
      final original = StackTrace.current;
      final filtered = filterStackTrace(original).toString().trim();

      expect(filtered, equals(original.toString().trim()));
    });

    test('parses an empty stacktrace', () {
      const original = StackTrace.empty;
      final filtered = filterStackTrace(original).toString().trim();

      expect(filtered, equals(original.toString().trim()));
    });

    test('removes the head of an example stacktrace', () {
      final original = StackTrace.fromString(
          '''       at guardWithCrashlytics.<fn>.<fn>(crashlytics.dart:32)
       at _BroadcastStreamController.add(_BroadcastStreamController.java)
       at Logger._publish(logger.dart:276)
       at Logger.log(logger.dart:200)
       at Logger.severe(logger.dart:258)
       at GamesServicesController.initialize(games_services.dart:23)''');
      final filtered = filterStackTrace(original).toString().trim();

      expect(filtered, isNot(original.toString().trim()));
      expect(filtered, isNot(contains('at guardWithCrashlytics')));
      expect(filtered, contains('at GamesServicesController'));
    });
  });
}
