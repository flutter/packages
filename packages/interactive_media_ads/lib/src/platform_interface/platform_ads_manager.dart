// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'platform_ads_manager_delegate.dart';

base class AdsManagerInitParams {

}

base class AdsManagerStartParams {

}

/// Interface for a platform implementation of a `AdsManager`.
abstract base class PlatformAdsManager  {
  @protected
  PlatformAdsManager();

  void init(AdsManagerInitParams params);

  void start(AdsManagerStartParams params);

  void setAdsManagerDelegate(PlatformAdsManagerDelegate delegate);

  void destroy();
}
