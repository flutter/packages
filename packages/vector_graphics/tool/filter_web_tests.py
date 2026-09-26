#!/usr/bin/env python3
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Run the complete filter test suite in Chrome with actual web shader assets.

Flutter's browser test server does not serve package test fixtures or compile
native shader bundles to web shaders. A temporary host builds that asset bundle,
then runs unchanged copies of the package tests against the local packages.
The host and its failure logs can be retained with --host for investigation.
"""

import argparse
import base64
import json
import re
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--host', type=Path)
    parser.add_argument('--suite', action='append', help='Run only a named *_test suite (repeatable).')
    args = parser.parse_args()
    package = Path(__file__).resolve().parent.parent
    host = args.host or Path(tempfile.mkdtemp(prefix='svg-filter-web-'))
    host = host.resolve()
    flutter = shutil.which('flutter')
    if flutter is None:
        raise SystemExit('Put the Flutter SDK on PATH first.')
    host.mkdir(parents=True, exist_ok=True)
    print(f'Browser test host: {host}', flush=True)

    def run(*command):
        subprocess.run(command, cwd=host, check=True)

    if not (host / 'web').exists():
        run(flutter, 'create', '--platforms=web', '--project-name=filter_web_tests', '--no-pub', '.')
        (host / 'test/widget_test.dart').unlink(missing_ok=True)
    shaders = sorted((package / 'shaders').glob('*.frag'))
    assets = ['test/filters/fixtures/', 'test/filters/reference/', 'test/filters/files.json']
    if (package / 'test/filters/turbulence_samples.json').exists():
        assets.append('test/filters/turbulence_samples.json')
    pubspec = f'''name: filter_web_tests
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
dependency_overrides:
  vector_graphics_codec:
    path: {json.dumps(str(package.parent / 'vector_graphics_codec'))}
flutter:
  assets:
'''+''.join(f'    - {asset}\n' for asset in assets)
    if shaders:
        pubspec += '  shaders:\n'+''.join(f'    - shaders/{p.name}\n' for p in shaders)
    (host / 'pubspec.yaml').write_text(pubspec)
    (host / 'lib/main.dart').write_text(
        "import 'package:flutter/widgets.dart';\nvoid main() => runApp(const SizedBox());\n")
    shutil.copytree(package / 'test/filters', host / 'test/filters', dirs_exist_ok=True)
    fixtures = sorted(p.relative_to(host).as_posix() for p in (host / 'test/filters').rglob('*')
                      if p.is_file() and p.suffix in {'.svg', '.png', '.json'} and p.name != 'files.json')
    (host / 'test/filters/files.json').write_text(json.dumps(fixtures))
    if (package / 'shaders').exists():
        shutil.copytree(package / 'shaders', host / 'shaders', dirs_exist_ok=True)
    tests = sorted((package / 'test/filters').glob('*_test.dart'))
    if args.suite:
        tests = [p for p in tests if p.stem in args.suite]
        if len(tests) != len(set(args.suite)):
            raise SystemExit('An unknown suite was requested.')
    wrappers = host / 'test/browser'
    wrappers.mkdir(exist_ok=True)
    for p in wrappers.glob('*.dart'):
        p.unlink()
    for test in tests:
        runner = "import 'package:flutter_test/flutter_test.dart';\nimport '../filters/test_files.dart';\n"
        runner += f"import '../filters/{test.name}' as suite;\n"
        runner += '\nFuture<void> main() async {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  await loadTestFiles();\n  suite.main();\n}\n'
        (wrappers / test.name).write_text(runner)
    run(flutter, 'build', 'web', '--no-wasm-dry-run')
    asset_link = host / 'test/assets'
    if not asset_link.exists():
        asset_link.symlink_to('../build/web/assets', target_is_directory=True)
    browser_assets = wrappers / 'assets'
    if not browser_assets.exists():
        browser_assets.symlink_to('../../build/web/assets', target_is_directory=True)
    command = [flutter, 'test', '--platform=chrome', '--reporter=expanded', 'test/browser']
    failures = host / 'build/filter_failures'
    with subprocess.Popen(command, cwd=host, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True) as process:
        for line in process.stdout:
            artifact = re.search(r'FILTER_FAILURE_IMAGE:([a-zA-Z0-9_]+):([a-zA-Z0-9+/=]+)', line)
            if artifact:
                failures.mkdir(parents=True, exist_ok=True)
                (failures / f'{artifact[1]}.actual.png').write_bytes(base64.b64decode(artifact[2]))
            else:
                print(line, end='', flush=True)
        if process.wait():
            raise SystemExit(f'Browser tests failed. Visual artifacts: {failures}')


if __name__ == '__main__':
    main()
