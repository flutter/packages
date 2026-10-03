#!/usr/bin/env python3
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Run the filter suites in a macOS app on Impeller or Skia.

The temporary host bundles the same fixtures and shaders as the browser host.
This exercises the actual GPU renderer, not flutter_tester's software surface.
Use --host to retain build logs and visual failure artifacts.
"""

import argparse
import base64
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--host', type=Path)
    parser.add_argument('--renderer', choices=['impeller', 'skia'], default='impeller')
    parser.add_argument('--suite', action='append', help='Run only a named *_test suite (repeatable).')
    args = parser.parse_args()
    package = Path(__file__).resolve().parent.parent
    host = (args.host or Path(tempfile.mkdtemp(prefix='svg-filter-native-'))).resolve()
    flutter = shutil.which('flutter')
    if flutter is None:
        raise SystemExit('Put the Flutter SDK on PATH first.')
    host.mkdir(parents=True, exist_ok=True)
    print(f'Native test host: {host} ({args.renderer})', flush=True)

    def run(*command):
        subprocess.run(command, cwd=host, check=True)

    if not (host / 'macos').exists():
        run(flutter, 'create', '--platforms=macos', '--project-name=filter_native_tests', '--no-pub', '.')
        (host / 'test/widget_test.dart').unlink(missing_ok=True)
    shaders = sorted((package / 'shaders').glob('*.frag'))
    pubspec = f'''name: filter_native_tests
publish_to: none
environment:
  sdk: ^3.11.0
dependencies:
  flutter:
    sdk: flutter
  vector_graphics:
    path: {json.dumps(str(package))}
  vector_graphics_compiler:
    path: {json.dumps(str(package.parent / 'vector_graphics_compiler'))}
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
dependency_overrides:
  vector_graphics_codec:
    path: {json.dumps(str(package.parent / 'vector_graphics_codec'))}
flutter:
  assets:
    - test/filters/fixtures/
    - test/filters/reference/
    - test/filters/files.json
''' + ''.join(f'    - shaders/{p.name}\n' for p in shaders)
    (host / 'pubspec.yaml').write_text(pubspec)
    shutil.copytree(package / 'test/filters', host / 'test/filters', dirs_exist_ok=True)
    if shaders:
        shutil.copytree(package / 'shaders', host / 'shaders', dirs_exist_ok=True)
    fixtures = sorted(p.relative_to(host).as_posix() for p in (host / 'test/filters').rglob('*')
                      if p.is_file() and p.suffix in {'.svg', '.png', '.json'} and p.name != 'files.json')
    (host / 'test/filters/files.json').write_text(json.dumps(fixtures))
    # Test registration must finish synchronously: integration_test starts the
    # runner as soon as its first event-loop turn ends. Use absolute fixture
    # paths instead of awaiting platform asset loads during registration.
    entitlements = host / 'macos/Runner/DebugProfile.entitlements'
    entitlement_text = entitlements.read_text()
    entitlement_text = entitlement_text.replace(
        '<key>com.apple.security.app-sandbox</key>\n\t<true/>',
        '<key>com.apple.security.app-sandbox</key>\n\t<false/>')
    entitlements.write_text(entitlement_text)
    (host / 'test/filters/test_files_io.dart').write_text(f"""import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
final _root = {json.dumps(str(host))};
Uint8List readTestBytes(String path) => File('$_root/$path').readAsBytesSync();
String readTestString(String path) => utf8.decode(readTestBytes(path));
Future<void> loadTestFiles() async {{}}
void writeFailureImage(String name, Uint8List data) =>
  print('FILTER_FAILURE_IMAGE:$name:${{base64Encode(data)}}');
""")
    tests = sorted((package / 'test/filters').glob('*_test.dart'))
    if args.suite:
        tests = [p for p in tests if p.stem in args.suite]
        if len(tests) != len(set(args.suite)):
            raise SystemExit('An unknown suite was requested.')
    integration = host / 'integration_test'
    integration.mkdir(exist_ok=True)
    runner = "import 'package:integration_test/integration_test.dart';\n"
    runner += "import 'package:flutter_test/flutter_test.dart';\n"
    runner += ''.join(f"import '../test/filters/{p.name}' as suite_{i};\n"
                      for i, p in enumerate(tests))
    runner += '\nvoid main() {\n'
    runner += '  IntegrationTestWidgetsFlutterBinding.ensureInitialized();\n'
    runner += ''.join(f"  group('{p.stem}', suite_{i}.main);\n" for i, p in enumerate(tests)) + '}\n'
    (integration / 'filters_test.dart').write_text(runner)
    driver = host / 'test_driver'
    driver.mkdir(exist_ok=True)
    (driver / 'filter_driver.dart').write_text(
        "import 'package:integration_test/integration_test_driver.dart';\n"
        "Future<void> main() => integrationDriver(timeout: const Duration(minutes: 20));\n")
    command = [flutter, 'drive', '--debug', '-d', 'macos',
               '--enable-impeller' if args.renderer == 'impeller' else '--no-enable-impeller',
               '--driver=test_driver/filter_driver.dart', '--target=integration_test/filters_test.dart']
    failures = host / 'build/filter_failures'
    had_failure = False
    test_count = 0
    with subprocess.Popen(command, cwd=host, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True) as process:
        for line in process.stdout:
            had_failure |= '[E]' in line or 'Some tests failed' in line
            count = re.search(r'\d+:\d+ \+(\d+)', line)
            if count:
                test_count = max(test_count, int(count[1]))
            artifact = re.search(r'FILTER_FAILURE_IMAGE:([a-zA-Z0-9_]+):([a-zA-Z0-9+/=]+)', line)
            if artifact:
                failures.mkdir(parents=True, exist_ok=True)
                (failures / f'{artifact[1]}.actual.png').write_bytes(base64.b64decode(artifact[2]))
            else:
                print(line, end='', flush=True)
        if process.wait() or had_failure or test_count < len(tests):
            raise SystemExit(f'Native tests failed. Visual artifacts: {failures}')


if __name__ == '__main__':
    main()
