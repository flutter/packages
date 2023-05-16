// Copyright 2017 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// //////////////////////////////////////////////////////////
//
// This file is a stripped down, and slightly modified version of
// package:platform_detect's.
//
// Original version here: https://github.com/Workiva/platform_detect
//
// //////////////////////////////////////////////////////////

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Determines if the `navigator` is Safari.
bool navigatorIsSafari(web.Navigator navigator) {
  // An web view running in an iOS app does not have a 'Version/X.X.X' string in the appVersion
  final String vendor = navigator.vendor.toDart;
  final String appVersion = navigator.appVersion.toDart;
  return vendor != null &&
      vendor.contains('Apple') &&
      appVersion != null &&
      appVersion.contains('Version');
}
