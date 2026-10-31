// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'test_cases/adaptive_streaming.dart' as adaptive_streaming;
import 'test_cases/playback.dart' as playback;
import 'test_cases/sources_tracks.dart' as sources_tracks;

void main() {
  playback.main();
  sources_tracks.main();
  adaptive_streaming.main();
}
