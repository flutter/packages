import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IndoorLevel', () {
    test('constructor', () {
      const String expectedName = 'some-name';
      const String expectedShortName = 'some-short-name';
      const IndoorLevel indoorLevel = IndoorLevel(
        name: expectedName,
        shortName: expectedShortName,
      );

      expect(indoorLevel.name, expectedName);
      expect(indoorLevel.shortName, expectedShortName);
    });

    test('fromJson', () {
      const String expectedName = 'some-name';
      const String expectedShortName = 'some-short-name';
      final IndoorLevel? indoorLevel = IndoorLevel.fromJson(<String, String>{
        'name': expectedName,
        'shortName': expectedShortName,
      });

      expect(indoorLevel?.name, expectedName);
      expect(indoorLevel?.shortName, expectedShortName);
    });
  });
}
