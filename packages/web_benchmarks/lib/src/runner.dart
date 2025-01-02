// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert' show json;
import 'dart:io' as io;

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:process/process.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

import 'benchmark_result.dart';
import 'browser.dart';
import 'common.dart';
import 'compilation_options.dart';
import 'metrics.dart';

/// The default port number used by the local benchmark server.
const int defaultBenchmarkServerPort = 9999;

/// The default port number used for Chrome DevTool Protocol.
const int defaultChromeDebugPort = 10000;

/// Builds and serves a Flutter Web app, collects raw benchmark data and
/// summarizes the result as a [BenchmarkResult].
class BenchmarkServer {
  /// Creates a benchmark server.
  ///
  /// [benchmarkAppDirectory] is the directory containing the app that's being
  /// benchmarked. The app is expected to use `package:web_benchmarks/client.dart`
  /// and call the `runBenchmarks` function to run the benchmarks.
  ///
  /// [entryPoint] is the path to the main app file that runs the benchmark. It
  /// can be different (and typically is) from the production entry point of the
  /// app.
  ///
  /// [benchmarkServerPort] is the port this benchmark server serves the app on.
  ///
  /// [chromeDebugPort] is the port Chrome uses for DevTool Protocol used to
  /// extract tracing data.
  ///
  /// If [headless] is true, runs Chrome without UI. In particular, this is
  /// useful in environments (e.g. CI) that doesn't have a display.
  ///
  /// If [treeShakeIcons] is false, '--no-tree-shake-icons' will be passed as a
  /// build argument when building the benchmark app.
  ///
  /// [compilationOptions] specify the compiler and renderer to use for the
  /// benchmark app. This can either use dart2wasm & skwasm or
  /// dart2js & canvaskit.
  ///
  /// [benchmarkPath] specifies the path for the URL that will be loaded upon
  /// opening the benchmark app in Chrome.
  BenchmarkServer({
    required this.benchmarkAppDirectory,
    required this.entryPoint,
    required this.benchmarkServerPort,
    required this.chromeDebugPort,
    required this.headless,
    required this.treeShakeIcons,
    this.compilationOptions = const CompilationOptions.js(),
    this.benchmarkPath = defaultInitialPath,
  });

  final ProcessManager _processManager = const LocalProcessManager();

  /// The directory containing the app that's being benchmarked.
  ///
  /// The app is expected to use `package:web_benchmarks/client.dart`
  /// and call the `runBenchmarks` function to run the benchmarks.
  final io.Directory benchmarkAppDirectory;

  /// The path to the main app file that runs the benchmark.
  ///
  /// It can be different (and typically is) from the production entry point of
  /// the app.
  final String entryPoint;

  /// The compilation options to use for building the benchmark web app.
  final CompilationOptions compilationOptions;

  /// The port this benchmark server serves the app on.
  final int benchmarkServerPort;

  /// The port Chrome uses for DevTool Protocol used to extract tracing data.
  final int chromeDebugPort;

  /// Whether to run Chrome without UI.
  ///
  /// This is useful in environments (e.g. CI) that doesn't have a display.
  final bool headless;

  /// Whether to tree shake icons during the build.
  ///
  /// When false, '--no-tree-shake-icons' will be passed as a build argument.
  final bool treeShakeIcons;

  /// The initial path for the URL that will be loaded upon opening the
  /// benchmark app in Chrome.
  ///
  /// This path should contain the path segments, fragment, and/or query
  /// parameters that are required for the benchmark. This value will be parsed
  /// by `Uri.parse` and combined with the benchmark URI scheme ('http'), host
  /// ('localhost'), and port [benchmarkServerPort] to create the URL for
  /// loading in Chrome. See [_benchmarkAppUrl].
  ///
  /// The default value is [defaultInitialPath].
  final String benchmarkPath;

  String get _benchmarkAppUrl => Uri.parse(benchmarkPath)
      .replace(
        scheme: 'http',
        host: 'localhost',
        port: benchmarkServerPort,
      )
      .toString();

  /// Builds and serves the benchmark app, and collects benchmark results.
  Future<BenchmarkResults> run() async {
    // Reduce logging level. Otherwise, package:webkit_inspection_protocol is way too spammy.
    Logger.root.level = Level.INFO;

    if (!_processManager.canRun('flutter')) {
      throw Exception(
          "flutter executable is not runnable. Make sure it's in the PATH.");
    }

    final DateTime startTime = DateTime.now();
    print('Building Flutter web app $compilationOptions...');
    final io.ProcessResult buildResult = await _processManager.run(
      <String>[
        'flutter',
        'build',
        'web',
        if (compilationOptions.useWasm) ...<String>[
          '--wasm',
          '--no-strip-wasm',
        ],
        '--dart-define=FLUTTER_WEB_ENABLE_PROFILING=true',
        if (!treeShakeIcons) '--no-tree-shake-icons',
        '--profile',
        '-t',
        entryPoint,
      ],
      workingDirectory: benchmarkAppDirectory.path,
    );

    final int buildTime = Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch -
          startTime.millisecondsSinceEpoch,
    ).inSeconds;
    print('Build took ${buildTime}s to complete.');

    if (buildResult.exitCode != 0) {
      io.stderr.writeln(buildResult.stdout);
      io.stderr.writeln(buildResult.stderr);
      throw Exception('Failed to build the benchmark.');
    }

    final Completer<List<Map<String, dynamic>>> profileData =
        Completer<List<Map<String, dynamic>>>();
    final List<Map<String, dynamic>> collectedProfiles =
        <Map<String, dynamic>>[];
    List<String>? benchmarks;
    late Iterator<String> benchmarkIterator;

    // This future fixes a race condition between the web-page loading and
    // asking to run a benchmark, and us connecting to Chrome's DevTools port.
    // Sometime one wins. Other times, the other wins.
    Future<Chrome>? whenChromeIsReady;
    Chrome? chrome;
    late io.HttpServer server;
    List<Map<String, dynamic>>? latestPerformanceTrace;
    Cascade cascade = Cascade();

    // Serves the static files built for the app (html, js, images, fonts, etc)
    final Handler buildFolderHandler = createStaticHandler(
      path.join(benchmarkAppDirectory.path, 'build', 'web'),
      defaultDocument: 'index.html',
    );

    // We want our page to be crossOriginIsolated. This will allow us to run the
    // skwasm renderer, which uses a SharedArrayBuffer, which requires the page
    // to be crossOriginIsolated. But also, even in the non-skwasm case, running
    // in crossOriginIsolated gives us access to more accurate timers which are
    // useful for capturing good benchmarking data.
    // See https://developer.mozilla.org/en-US/docs/Web/API/Performance_API/High_precision_timing#reduced_precision
    cascade = cascade.add((Request request) async {
      final Response response = await buildFolderHandler(request);
      if (response.mimeType == 'text/html') {
        return response.change(headers: <String, String>{
          'Cross-Origin-Opener-Policy': 'same-origin',
          'Cross-Origin-Embedder-Policy': 'require-corp',
        });
      }
      return response;
    });

    // Serves the benchmark server API used by the benchmark app to coordinate
    // the running of benchmarks.
    cascade = cascade.add((Request request) async {
      try {
        chrome ??= await whenChromeIsReady;
        if (request.requestedUri.path.endsWith('/profile-data')) {
          final Map<String, dynamic> profile =
              json.decode(await request.readAsString()) as Map<String, dynamic>;
          final String? benchmarkName = profile['name'] as String?;
          if (benchmarkName != benchmarkIterator.current) {
            profileData.completeError(Exception(
              'Browser returned benchmark results from a wrong benchmark.\n'
              'Requested to run benchmark ${benchmarkIterator.current}, but '
              'got results for $benchmarkName.',
            ));
            unawaited(server.close());
          }

          // Trace data is null when the benchmark is not frame-based, such as RawRecorder.
          if (latestPerformanceTrace != null) {
            final BlinkTraceSummary? traceSummary =
                BlinkTraceSummary.fromJson(latestPerformanceTrace!);
            profile[totalUiFrameAverage] =
                traceSummary?.averageTotalUIFrameTime.inMicroseconds;
            profile['scoreKeys'] ??=
                <dynamic>[]; // using dynamic for consistency with JSON
            (profile['scoreKeys'] as List<dynamic>).add(totalUiFrameAverage);
            latestPerformanceTrace = null;
          }
          collectedProfiles.add(profile);
          return Response.ok('Profile received');
        } else if (request.requestedUri.path
            .endsWith('/start-performance-tracing')) {
          latestPerformanceTrace = null;
          await chrome!.beginRecordingPerformance(
              request.requestedUri.queryParameters['label']);
          return Response.ok('Started performance tracing');
        } else if (request.requestedUri.path
            .endsWith('/stop-performance-tracing')) {
          latestPerformanceTrace = await chrome!.endRecordingPerformance();
          return Response.ok('Stopped performance tracing');
        } else if (request.requestedUri.path.endsWith('/on-error')) {
          final Map<String, dynamic> errorDetails =
              json.decode(await request.readAsString()) as Map<String, dynamic>;
          unawaited(server.close());
          // Keep the stack trace as a string. It's thrown in the browser, not this Dart VM.
          final String errorMessage =
              'Caught browser-side error: ${errorDetails['error']}\n${errorDetails['stackTrace']}';
          if (!profileData.isCompleted) {
            profileData.completeError(errorMessage);
          } else {
            io.stderr.writeln(errorMessage);
          }
          return Response.ok('');
        } else if (request.requestedUri.path.endsWith('/next-benchmark')) {
          if (benchmarks == null) {
            benchmarks =
                (json.decode(await request.readAsString()) as List<dynamic>)
                    .cast<String>();
            benchmarkIterator = benchmarks!.iterator;
          }
          if (benchmarkIterator.moveNext()) {
            final String nextBenchmark = benchmarkIterator.current;
            print('Launching benchmark "$nextBenchmark"');
            return Response.ok(nextBenchmark);
          } else {
            profileData.complete(collectedProfiles);
            return Response.ok(kEndOfBenchmarks);
          }
        } else if (request.requestedUri.path.endsWith('/print-to-console')) {
          // A passthrough used by
          // `dev/benchmarks/macrobenchmarks/lib/web_benchmarks.dart`
          // to print information.
          final String message = await request.readAsString();
          print('[APP] $message');
          return Response.ok('Reported.');
        } else {
          return Response.notFound(
              'This request is not handled by the profile-data handler.');
        }
      } catch (error, stackTrace) {
        if (!profileData.isCompleted) {
          profileData.completeError(error, stackTrace);
        } else {
          io.stderr.writeln('Caught error: $error');
          io.stderr.writeln('$stackTrace');
        }
        return Response.internalServerError(body: '$error');
      }
    });

    // If all previous handlers returned HTTP 404, this handler either serves
    // the static handler at the default document (for GET requests only) or
    // warns about the unrecognized path.
    cascade = cascade.add((Request request) async {
      if (request.method == 'GET') {
        final Uri newRequestUri = request.requestedUri.replace(path: '/');
        final Request newRequest = Request(
          request.method,
          newRequestUri,
          headers: request.headers,
        );
        return await buildFolderHandler(newRequest);
      }

      io.stderr.writeln('Unrecognized URL path: ${request.requestedUri.path}');
      return Response.notFound('Not found: ${request.requestedUri.path}');
    });

    server = await io.HttpServer.bind('localhost', benchmarkServerPort);
    try {
      shelf_io.serveRequests(server, cascade.handler);

      final String dartToolDirectory =
          path.join(benchmarkAppDirectory.path, '.dart_tool');
      final String userDataDir = io.Directory(dartToolDirectory)
          .createTempSync('chrome_user_data_')
          .path;

      final ChromeOptions options = ChromeOptions(
        url: _benchmarkAppUrl,
        userDataDirectory: userDataDir,
        headless: headless,
        debugPort: chromeDebugPort,
      );

      print('Launching Chrome.');
      whenChromeIsReady = Chrome.launch(
        options,
        onError: (String error) {
          if (!profileData.isCompleted) {
            profileData.completeError(Exception(error));
          } else {
            io.stderr.writeln('Chrome error: $error');
          }
        },
        workingDirectory: benchmarkAppDirectory.path,
      );

      print('Waiting for the benchmark to report benchmark profile.');
      final List<Map<String, dynamic>> profiles = await profileData.future;

      print('Received profile data');
      final Map<String, List<BenchmarkScore>> results =
          <String, List<BenchmarkScore>>{};
      for (final Map<String, dynamic> profile in profiles) {
        final String benchmarkName = profile['name'] as String;
        if (benchmarkName.isEmpty) {
          throw StateError('Benchmark name is empty');
        }

        final List<String> scoreKeys =
            List<String>.from(profile['scoreKeys'] as Iterable<dynamic>);
        if (scoreKeys.isEmpty) {
          throw StateError('No score keys in benchmark "$benchmarkName"');
        }
        for (final String scoreKey in scoreKeys) {
          if (scoreKey.isEmpty) {
            throw StateError(
                'Score key is empty in benchmark "$benchmarkName". '
                'Received [${scoreKeys.join(', ')}]');
          }
        }

        final List<BenchmarkScore> scores = <BenchmarkScore>[];
        for (final String key in profile.keys) {
          if (key == 'name' || key == 'scoreKeys') {
            continue;
          }
          scores.add(BenchmarkScore(
            metric: key,
            value: profile[key] as num,
          ));
        }
        results[benchmarkName] = scores;
      }
      return BenchmarkResults(results);
    } finally {
      if (headless) {
        chrome?.stop();
      } else {
        // In non-headless mode wait for the developer to close Chrome
        // manually. Otherwise, they won't get a chance to debug anything.
        print(
          'Benchmark finished. Chrome running in windowed mode. Close '
          'Chrome manually to continue.',
        );
        await chrome?.whenExits;
      }
      unawaited(server.close());
    }
  }
}
