import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mustache/mustache.dart';
import 'package:imitation_game/README_template.dart';
import 'package:args/args.dart';

// ignore_for_file: avoid_as

const int _port = 4040;

Future<String> _findIpAddress() async {
  String result;
  final List<NetworkInterface> interfaces = await NetworkInterface.list();
  for (NetworkInterface interface in interfaces) {
    for (InternetAddress address in interface.addresses) {
      if (address.type == InternetAddressType.IPv4) {
        // TODO(gaaclarke): Implment having multiple addresses.
        assert(result == null);
        result = address.address;
      }
    }
  }
  return result;
}

Future<String> _getFlutterVersion() async {
  String result = '';
  final Process flutterVersion =
      await Process.start('flutter', <String>['--version']);
  flutterVersion.stdout.transform(utf8.decoder).listen((String event) {
    result += event;
  });
  await flutterVersion.exitCode;
  return result.trim();
}

typedef FileFilter = bool Function(FileSystemEntity);
Future<List<FileSystemEntity>> findFiles(Directory dir, {FileFilter where}) {
  final List<FileSystemEntity> files = <FileSystemEntity>[];
  final Completer<List<FileSystemEntity>> completer =
      Completer<List<FileSystemEntity>>();
  final Stream<FileSystemEntity> lister = dir.list(recursive: true);
  lister.listen((FileSystemEntity file) {
    if (where == null || where(file)) {
      files.add(file);
    }
  }, onDone: () => completer.complete(files));
  return completer.future;
}

Future<String> _makeMarkdownOutput(Map<String, dynamic> results) async {
  // TODO(gaaclarke): Add the Flutter version.
  final Template template = Template(readmeTemplate, name: 'README.md');
  final Map<String, dynamic> values = Map<String, dynamic>.from(results);
  values['date'] = DateTime.now().toUtc();
  values['flutterVersion'] = await _getFlutterVersion();
  final String output = template.renderString(values);
  return output;
}

/// This merges [newResults] into [oldResults] such the union of the keys will
/// have their values from [newResults] and the symmetric difference will have the
/// value from their respective sets.
Map<String, dynamic> _integrate(
    {Map<String, dynamic> oldResults, Map<String, dynamic> newResults}) {
  final Map<String, dynamic> result = Map<String, dynamic>.from(oldResults);
  newResults.forEach((String test, dynamic testValue) {
    final Map<String, dynamic> testMap = testValue as Map<String, dynamic>;
    testMap.forEach((String platform, dynamic platformValue) {
      final Map<String, dynamic> platformMap =
          platformValue as Map<String, dynamic>;
      platformMap.forEach((String measurement, dynamic measurementValue) {
        if (!result.containsKey(test)) {
          result[test] = <String, dynamic>{};
        }
        if (!result[test].containsKey(platform)) {
          result[test][platform] = <String, dynamic>{};
        }
        result[test][platform][measurement] = measurementValue;
      });
    });
  });
  return result;
}

class _Script {
  _Script({this.path});
  String path;
}

class _ScriptRunner {
  _ScriptRunner(this._scriptPaths);

  final List<String> _scriptPaths;
  Process _currentProcess;
  StreamSubscription<String> _stdoutSubscription;
  StreamSubscription<String> _stderrSubscription;

  Future<_Script> runNext() async {
    if (_currentProcess != null) {
      _stdoutSubscription.cancel();
      _stderrSubscription.cancel();
      _currentProcess.kill();
      _currentProcess = null;
    }

    if (_scriptPaths.isEmpty) {
      return null;
    } else {
      final String path = _scriptPaths.last;
      print('running: $path');
      _scriptPaths.removeLast();
      _currentProcess = await Process.start('sh', <String>[path]);
      // TODO(gaaclarke): Implement a timeout.
      _stdoutSubscription =
          _currentProcess.stdout.transform(utf8.decoder).listen((String data) {
        print(data);
      });
      _stderrSubscription =
          _currentProcess.stderr.transform(utf8.decoder).listen((String data) {
        print(data);
      });
      return _Script(path: path);
    }
  }
}

/// Recursively converts a map of maps to a map of lists of maps.
///
/// For example:
/// _map2List({'a': {'b': 123}}, ['foo', 'bar']) ->
/// {
///   'foo':[
///     {
///       'name': 'a',
///       'bar': [{'name': 'b', 'value': 123}]
///     }
///   ]
/// }
Map<String, dynamic> _map2List(Map<String, dynamic> map, List<String> names) {
  final List<Map<String, dynamic>> returnList = <Map<String, dynamic>>[];
  final List<String> tail = names.sublist(1);
  map.forEach((String key, dynamic value) {
    final Map<String, dynamic> testResult = <String, dynamic>{'name': key};
    if (tail.isEmpty) {
      testResult['value'] = value;
    } else {
      testResult[tail.first] = _map2List(value, tail)[tail.first];
    }
    returnList.add(testResult);
  });
  return <String, dynamic>{names.first: returnList};
}

class _ImitationGame {
  final Map<String, dynamic> results = <String, dynamic>{};
  _ScriptRunner _scriptRunner;
  _Script _currentScript;

  Future<bool> start(List<String> iosScripts) {
    _scriptRunner = _ScriptRunner(iosScripts);
    return _runNext();
  }

  Future<bool> handleResult(Map<String, dynamic> data) {
    final String test = data['test'];
    final String platform = data['platform'];
    results.putIfAbsent(test, () => <String, dynamic>{});
    results[test].putIfAbsent(platform, () => <String, dynamic>{});
    data['results'].forEach((String k, dynamic v) {
      // ignore: avoid_as
      results[test][platform][k] = v as double;
    });
    return _runNext();
  }

  Future<bool> handleTimeout() {
    return _runNext();
  }

  Future<bool> _runNext() async {
    _currentScript = await _scriptRunner.runNext();
    return _currentScript != null;
  }
}

enum _TargetPlatform { ANDROID, IOS }

Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser();
  parser.addOption('platform',
      allowed: <String>['android', 'ios'], defaultsTo: 'android');
  final ArgResults parserResults = parser.parse(args);
  final _TargetPlatform targetPlatform = parserResults['platform'] == 'android'
      ? _TargetPlatform.ANDROID
      : _TargetPlatform.IOS;

  final HttpServer server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    _port,
  );
  final String ipaddress = await _findIpAddress();
  print('Listening on $ipaddress:${server.port}');

  for (FileSystemEntity entity in await findFiles(Directory.current,
      where: (FileSystemEntity f) => f.path.endsWith('ip.txt'))) {
    final File file = File(entity.path);
    file.writeAsStringSync('$ipaddress:${server.port}');
  }

  final String scriptName = (targetPlatform == _TargetPlatform.ANDROID)
      ? 'run_android.sh'
      : () {
          assert(targetPlatform == _TargetPlatform.IOS);
          return 'run_ios.sh';
        }();
  final List<String> scripts = (await findFiles(Directory.current,
          where: (FileSystemEntity f) => f.path.endsWith(scriptName)))
      .map((FileSystemEntity e) => e.path)
      .toList();

  if (scripts.isEmpty) {
    return;
  }

  final _ImitationGame game = _ImitationGame();
  bool keepRunning = await game.start(scripts);

  while (keepRunning) {
    try {
      final Stream<HttpRequest> timeoutServer = server.timeout(
          const Duration(minutes: 5), onTimeout: (EventSink<HttpRequest> sink) {
        print('TIMEOUT!');
        throw TimeoutException('timeout');
      });
      await for (HttpRequest request in timeoutServer) {
        print('got request: ${request.method}');
        if (request.method == 'POST') {
          final String content = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> data =
              // ignore: avoid_as
              jsonDecode(content) as Map<String, dynamic>;
          print('$data');
          keepRunning = await game.handleResult(data);
          if (!keepRunning) {
            break;
          }
        } else {
          request.response.write('use post');
        }
        await request.response.close();
      }
    } on TimeoutException catch (_) {
      keepRunning = await game.handleTimeout();
    }
  }

  // TODO(gaaclarke): Add a log of what Flutter version generated the numbers.
  const String lastResultsFilename = 'last_results.json';
  const JsonDecoder decoder = JsonDecoder();
  final Map<String, dynamic> lastResults =
      decoder.convert(File(lastResultsFilename).readAsStringSync())
          // ignore: avoid_as
          as Map<String, dynamic>;

  // TODO(aaclarke): Calculate the generation time for each measurement since we
  // can't generate everything in one pass (because you are running iOS or Android).
  final Map<String, dynamic> totalResults =
      _integrate(newResults: game.results, oldResults: lastResults);

  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  final String jsonResults = encoder.convert(totalResults);
  File(lastResultsFilename).writeAsStringSync(jsonResults);

  final Map<String, dynamic> markdownValues =
      _map2List(totalResults, <String>['tests', 'platforms', 'measurements']);
  File('README.md')
      .writeAsStringSync(await _makeMarkdownOutput(markdownValues));
  await server.close(force: true);
}
