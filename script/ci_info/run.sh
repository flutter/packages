#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Runs one of the ci_info scripts, e.g.:
#   script/ci_info/run.sh find_builds --pr 1234
#
# Prefers the Dart SDK binary bundled with Flutter over Flutter's `dart`
# wrapper, which takes Flutter's startup lock and so serializes (and prints
# "Waiting for another flutter command...") when scripts run in parallel.
set -e

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <script> [args...]" >&2
  exit 64
fi

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script="${1%.dart}"
shift

dart="$(command -v dart)"
# Resolve symlinks without `readlink -f`, which macOS lacks.
while [[ -L "$dart" ]]; do
  target="$(readlink "$dart")"
  if [[ "$target" == /* ]]; then
    dart="$target"
  else
    dart="$(dirname "$dart")/$target"
  fi
done
sdk_dart="$(dirname "$dart")/cache/dart-sdk/bin/dart"
if [[ -x "$sdk_dart" ]]; then
  dart="$sdk_dart"
fi

if [[ ! -f "$dir/.dart_tool/package_config.json" ]]; then
  "$dart" pub get -C "$dir" >&2
fi

exec "$dart" run "$dir/bin/$script.dart" "$@"
