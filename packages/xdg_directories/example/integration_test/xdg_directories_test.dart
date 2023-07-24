import 'dart:io' show Platform;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xdg_directories/xdg_directories.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('XDG Directories', (WidgetTester _) async {
    // Check that the test is running on Linux.
    if (!Platform.isLinux) {
      throw Exception('This test is only valid on Linux');
    }

    // Check that the XDG directories are not empty.
    expect(
      getUserDirectoryNames().length,
      isNot(0),
      reason: 'getUserDirectoryNames() should return a non-empty Set<String>',
    );

    final Set<String> userDirectoryNames = getUserDirectoryNames();

    // Check that getUserDirectory() returns a Directory.
    expect(
      getUserDirectory(userDirectoryNames.first) != null,
      true,
      reason: 'getUserDirectory() should return a Directory',
    );

    // Check that dataHome returns a Directory.
    expect(
      dataHome.path.isNotEmpty,
      true,
      reason: 'dataHome should return a Directory',
    );

    // Check that configHome returns a Directory.
    expect(
      configHome.path.isNotEmpty,
      true,
      reason: 'configHome should return a Directory',
    );

    // Check that cacheHome returns a Directory.
    expect(
      cacheHome.path.isNotEmpty,
      true,
      reason: 'cacheHome should return a Directory',
    );

    // Check that dataDirs returns a List<Directory>.
    expect(
      dataDirs.isNotEmpty,
      true,
      reason: 'dataDirs should return a List<Directory>',
    );

    // Check that configDirs returns a List<Directory>.
    expect(
      configDirs.isNotEmpty,
      true,
      reason: 'configDirs should return a List<Directory>',
    );
  });
}
