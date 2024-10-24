// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #docregion main-example
import 'package:google_adsense_ad_placement_api_web/google_adsense_ad_placement_api_web.dart';

void main() {
  adPlacementApi.adBreak(
    name: 'rewarded-example',
    type: BreakType.reward,
  );
}
// #enddocregion main-example
