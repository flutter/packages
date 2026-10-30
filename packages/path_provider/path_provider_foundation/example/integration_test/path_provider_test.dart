// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_foundation/src/ffi_bindings.g.dart';
import 'package:path_provider_foundation/src/foundation_paths.dart';
import 'package:path_provider_foundation/src/path_provider_foundation_real.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'path_provider_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<FoundationPaths>(),
  MockSpec<ObjCObject>(),
  MockSpec<PathProviderPlatformProvider>(),
])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // This group contains standard integration tests that do end-to-end testing
  // of the calls into the platform.
  group('end-to-end', () {
    testWidgets('getTemporaryDirectory', (WidgetTester tester) async {
      final PathProviderPlatform provider = PathProviderPlatform.instance;
      final String? result = await provider.getTemporaryPath();
      // getTemporaryPath does not guarantee that the returned directory exists.
      _verifySampleFile(result, 'temporaryDirectory', createDirectory: true);
    });

    testWidgets('getApplicationDocumentsDirectory', (WidgetTester tester) async {
      final PathProviderPlatform provider = PathProviderPlatform.instance;
      final String? result = await provider.getApplicationDocumentsPath();
      if (Platform.isMacOS) {
        // _verifySampleFile causes hangs in driver when sandboxing is disabled
        // because the path changes from an app specific directory to
        // ~/Documents, which requires additional permissions to access on macOS.
        // Instead, validate that a non-empty path was returned.
        expect(result, isNotEmpty);
      } else {
        _verifySampleFile(result, 'applicationDocuments');
      }
    });

    testWidgets('getApplicationSupportDirectory', (WidgetTester tester) async {
      final PathProviderPlatform provider = PathProviderPlatform.instance;
      final String? result = await provider.getApplicationSupportPath();
      _verifySampleFile(result, 'applicationSupport');
    });

    testWidgets('getApplicationCacheDirectory', (WidgetTester tester) async {
      final PathProviderPlatform provider = PathProviderPlatform.instance;
      final String? result = await provider.getApplicationCachePath();
      _verifySampleFile(result, 'applicationCache');
    });

    testWidgets('getLibraryDirectory', (WidgetTester tester) async {
      final PathProviderPlatform provider = PathProviderPlatform.instance;
      final String? result = await provider.getLibraryPath();
      _verifySampleFile(result, 'library');
    });

    testWidgets('getDownloadsDirectory', (WidgetTester tester) async {
      final PathProviderPlatform provider = PathProviderPlatform.instance;
      final String? result = await provider.getDownloadsPath();
      // _verifySampleFile causes hangs in driver for some reason, so just
      // validate that a non-empty path was returned.
      expect(result, isNotEmpty);
    });

    testWidgets('getContainerDirectory', (WidgetTester tester) async {
      if (Platform.isIOS) {
        final provider = PathProviderFoundation();
        final String? result = await provider.getContainerPath(
          appGroupIdentifier: 'group.flutter.appGroupTest',
        );
        _verifySampleFile(result, 'appGroup');
      }
    });
  });

  // These tests check what the plain-FFI reader answers against what the
  // Objective-C bindings answer, in the real runtime.
  group('FoundationPaths', () {
    final directories = <NSSearchPathDirectory>[
      NSSearchPathDirectory.NSApplicationSupportDirectory,
      NSSearchPathDirectory.NSCachesDirectory,
      NSSearchPathDirectory.NSDocumentDirectory,
      NSSearchPathDirectory.NSLibraryDirectory,
      NSSearchPathDirectory.NSDownloadsDirectory,
    ];

    for (final directory in directories) {
      testWidgets('userDirectory matches NSSearchPathForDirectoriesInDomains for $directory', (
        _,
      ) async {
        final foundation = FoundationFFI(
          DynamicLibrary.open('/System/Library/Frameworks/Foundation.framework/Foundation'),
        );
        final NSArray paths = foundation.NSSearchPathForDirectoriesInDomains(
          directory,
          NSSearchPathDomainMask.NSUserDomainMask,
          true,
        );
        final ObjCObject? first = paths.firstObject;
        final String? expected = first == null ? null : NSString.as(first).toDartString();

        expect(const FoundationPaths().userDirectory(directory), expected);
        expect(expected, isNotEmpty);
      });
    }

    testWidgets('mainBundleIdentifier matches NSBundle', (_) async {
      final String? expected = NSBundle.getMainBundle().bundleIdentifier?.toDartString();

      expect(const FoundationPaths().mainBundleIdentifier, expected);
      expect(expected, _bundleIdentifier);
    });
  });

  // This group contains tests that would normally be Dart unit tests in the
  // test/ directory, but can't be because they use Objective-C types (NSURL,
  // NSString, etc.) that aren't available in an actual unit test. For these
  // tests, the platform is stubbed out.
  group('unit', () {
    final platformVariants = ValueVariant<FakePlatformProvider>(<FakePlatformProvider>{
      FakePlatformProvider(isIOS: true),
      FakePlatformProvider(isMacOS: true),
    });

    // These tests use the actual filesystem, since an injectable filesystem
    // would add a runtime dependency to the package, so everything is contained
    // to a temporary directory.
    late Directory testRoot;

    setUp(() async {
      testRoot = Directory.systemTemp.createTempSync();
    });

    tearDown(() {
      testRoot.deleteSync(recursive: true);
    });

    testWidgets('getTemporaryPath iOS', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: FakePlatformProvider(isIOS: true),
      );

      final String temporaryPath = p.join(testRoot.path, 'temporary', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSCachesDirectory),
      ).thenReturn(temporaryPath);

      final String? path = await pathProvider.getTemporaryPath();

      expect(path, temporaryPath);
    });

    testWidgets('getTemporaryPath macOS', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: FakePlatformProvider(isMacOS: true),
      );

      final String temporaryPath = p.join(testRoot.path, 'temporary', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSCachesDirectory),
      ).thenReturn(temporaryPath);

      when(mockPaths.mainBundleIdentifier).thenReturn(_bundleIdentifier);

      final String? path = await pathProvider.getTemporaryPath();

      // On macOS, the bundle ID should be appended to the path.
      expect(path, '$temporaryPath/$_bundleIdentifier');
    });

    testWidgets('getApplicationSupportPath iOS', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: FakePlatformProvider(isIOS: true),
      );

      final String applicationSupportPath = p.join(testRoot.path, 'application', 'support', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSApplicationSupportDirectory),
      ).thenReturn(applicationSupportPath);

      final String? path = await pathProvider.getApplicationSupportPath();

      expect(path, applicationSupportPath);
    });

    testWidgets('getApplicationSupportPath macOS', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: FakePlatformProvider(isMacOS: true),
      );

      final String applicationSupportPath = p.join(testRoot.path, 'application', 'support', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSApplicationSupportDirectory),
      ).thenReturn(applicationSupportPath);

      when(mockPaths.mainBundleIdentifier).thenReturn(_bundleIdentifier);

      final String? path = await pathProvider.getApplicationSupportPath();

      // On macOS, the bundle ID should be appended to the path.
      expect(path, '$applicationSupportPath/$_bundleIdentifier');
    });

    testWidgets('getApplicationSupportPath creates the directory if necessary', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: platformVariants.currentValue,
      );

      final String applicationSupportPath = p.join(testRoot.path, 'application', 'support', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSApplicationSupportDirectory),
      ).thenReturn(applicationSupportPath);

      final String? path = await pathProvider.getApplicationSupportPath();

      expect(Directory(path!).existsSync(), isTrue);
    }, variant: platformVariants);

    testWidgets('getLibraryPath', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: platformVariants.currentValue,
      );

      final String libraryPath = p.join(testRoot.path, 'library', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSLibraryDirectory),
      ).thenReturn(libraryPath);

      final String? path = await pathProvider.getLibraryPath();

      expect(path, libraryPath);
    }, variant: platformVariants);

    testWidgets('getApplicationDocumentsPath', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: platformVariants.currentValue,
      );

      final String applicationDocumentsPath = p.join(
        testRoot.path,
        'application',
        'documents',
        'path',
      );
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSDocumentDirectory),
      ).thenReturn(applicationDocumentsPath);

      final String? path = await pathProvider.getApplicationDocumentsPath();

      expect(path, applicationDocumentsPath);
    }, variant: platformVariants);

    testWidgets('getApplicationCachePath iOS', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: FakePlatformProvider(isIOS: true),
      );

      final String applicationCachePath = p.join(testRoot.path, 'application', 'cache', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSCachesDirectory),
      ).thenReturn(applicationCachePath);

      final String? path = await pathProvider.getApplicationCachePath();

      expect(path, applicationCachePath);
    });

    testWidgets('getApplicationCachePath macOS', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: FakePlatformProvider(isMacOS: true),
      );

      final String applicationCachePath = p.join(testRoot.path, 'application', 'cache', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSCachesDirectory),
      ).thenReturn(applicationCachePath);

      when(mockPaths.mainBundleIdentifier).thenReturn(_bundleIdentifier);

      final String? path = await pathProvider.getApplicationCachePath();

      // On macOS, the bundle ID should be appended to the path.
      expect(path, '$applicationCachePath/$_bundleIdentifier');
    });

    testWidgets('getApplicationCachePath creates the directory if necessary', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: platformVariants.currentValue,
      );

      final String applicationCachePath = p.join(testRoot.path, 'application', 'cache', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSCachesDirectory),
      ).thenReturn(applicationCachePath);

      final String? path = await pathProvider.getApplicationCachePath();

      expect(Directory(path!).existsSync(), isTrue);
    }, variant: platformVariants);

    testWidgets('getDownloadsPath', (_) async {
      final mockPaths = MockFoundationPaths();
      final pathProvider = PathProviderFoundation(
        foundationPaths: mockPaths,
        platform: platformVariants.currentValue,
      );

      final String downloadsPath = p.join(testRoot.path, 'downloads', 'path');
      when(
        mockPaths.userDirectory(NSSearchPathDirectory.NSDownloadsDirectory),
      ).thenReturn(downloadsPath);

      final String? result = await pathProvider.getDownloadsPath();

      expect(result, downloadsPath);
    }, variant: platformVariants);

    testWidgets('getContainerPath', (_) async {
      final String containerPath = p.join(testRoot.path, 'container', 'path');
      final NSURL containerUrl = NSURL.fileURLWithPath(NSString(containerPath));

      final pathProvider = PathProviderFoundation(
        containerURLForSecurityApplicationGroupIdentifier: (_) => containerUrl,
        platform: FakePlatformProvider(isIOS: true),
      );

      const appGroupIdentifier = 'group.example.test';
      final String? result = await pathProvider.getContainerPath(
        appGroupIdentifier: appGroupIdentifier,
      );

      expect(result, containerPath);
    });
  });
}

const _bundleIdentifier = 'dev.flutter.plugins.pathProviderExample';

/// Verify a file called [name] in [directoryPath] by recreating it with test
/// contents when necessary.
///
/// If [createDirectory] is true, the directory will be created if missing.
void _verifySampleFile(String? directoryPath, String name, {bool createDirectory = false}) {
  expect(directoryPath, isNotNull);
  if (directoryPath == null) {
    return;
  }
  final directory = Directory(directoryPath);
  final file = File('${directory.path}${Platform.pathSeparator}$name');

  if (file.existsSync()) {
    file.deleteSync();
    expect(file.existsSync(), isFalse);
  }

  if (createDirectory && !directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  file.writeAsStringSync('Hello world!');
  expect(file.readAsStringSync(), 'Hello world!');
  expect(directory.listSync(), isNotEmpty);
  file.deleteSync();
}

/// Fake implementation of PathProviderPlatformProvider.
class FakePlatformProvider implements PathProviderPlatformProvider {
  FakePlatformProvider({this.isIOS = false, this.isMacOS = false}) : assert(isIOS != isMacOS);
  @override
  bool isIOS;

  @override
  bool isMacOS;

  @override
  String toString() => isIOS ? 'iOS' : 'macOS';
}
