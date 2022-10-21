// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_migrate/src/base/common.dart';
import 'package:flutter_migrate/src/base/context.dart';
import 'package:flutter_migrate/src/base/file_system.dart';
import 'package:flutter_migrate/src/base/io.dart';
import 'package:flutter_migrate/src/base/logger.dart';
import 'package:flutter_migrate/src/base/signals.dart';
import 'package:flutter_migrate/src/environment.dart';
import 'package:process/process.dart';

import 'src/common.dart';
import 'src/context.dart';

void main() {
  late FileSystem fileSystem;
  late BufferLogger logger;
  late ProcessManager processManager;
  late Directory appDir;

  setUp(() {
    fileSystem = LocalFileSystem.test(signals: LocalSignals.instance);
    appDir = fileSystem.systemTempDirectory.createTempSync('apptestdir');
    logger = BufferLogger.test();
    processManager = const LocalProcessManager();
  });

  tearDown(() async {
    tryToDelete(appDir);
  });

  Future<bool> flutterToolSupportsEnv() async {
    final ProcessResult result = await processManager
        .run(<String>['flutter', '--version'], workingDirectory: appDir.path);
    final String versionOutput = result.stdout as String;
    final List<String> versionSplit = versionOutput.substring(8, 14).split('.');
    expect(versionSplit.length >= 2, true);
    if (!(int.parse(versionSplit[0]) > 3 ||
        int.parse(versionSplit[0]) == 3 && int.parse(versionSplit[1]) > 3)) {
      // Apply not supported on stable version 3.3 and below
      return false;
    }
    return true;
  }

  testUsingContext('Environment initialization', () async {
    if (!(await flutterToolSupportsEnv())) {
      return;
    }
    final FlutterToolsEnvironment env =
        await FlutterToolsEnvironment.initializeFlutterToolsEnvironment(
            processManager, logger);
    expect(env.getString('invalid key') == null, true);
    expect(env.getBool('invalid key') == null, true);

    expect(env.getString('FlutterProject.directory') != null, true);
    expect(env.getString('FlutterProject.metadataFile') != null, true);
    expect(env.getBool('FlutterProject.android.exists'), false);
    expect(env.getBool('FlutterProject.ios.exists'), false);
    expect(env.getBool('FlutterProject.web.exists'), false);
    expect(env.getBool('FlutterProject.macos.exists'), false);
    expect(env.getBool('FlutterProject.linux.exists'), false);
    expect(env.getBool('FlutterProject.windows.exists'), false);
    expect(env.getBool('FlutterProject.fuchsia.exists'), false);
    expect(env.getBool('FlutterProject.android.isKotlin'), false);
    expect(env.getBool('FlutterProject.ios.isSwift'), false);
    expect(env.getBool('FlutterProject.isModule'), false);
    expect(env.getBool('FlutterProject.isPlugin'), false);
    expect(env.getString('FlutterProject.manifest.appname') != null, true);
    expect(env.getString('FlutterVersion.frameworkRevision') != null, true);
    final String os = isWindows
        ? 'windows'
        : isMacOS
            ? 'macos'
            : isLinux
                ? 'linux'
                : '';
    expect(env.getString('Platform.operatingSystem'), os);
    expect(env.getBool('Platform.isAndroid') != null, true);
    expect(env.getBool('Platform.isIOS') != null, true);
    expect(env.getBool('Platform.isWindows'), isWindows);
    expect(env.getBool('Platform.isMacOS'), isMacOS);
    expect(env.getBool('Platform.isFuchsia'), false);
    final String separator = isWindows ? r'\' : '/';
    expect(env.getString('Platform.pathSeparator'), separator);
    expect(env.getString('Cache.flutterRoot') != null, true);
  }, overrides: <Type, Generator>{
    FileSystem: () => fileSystem,
    ProcessManager: () => processManager,
  });
}
