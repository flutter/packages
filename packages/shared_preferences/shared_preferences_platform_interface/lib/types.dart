// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Filter options used to get and clear preferences.
class PreferencesFilter {
  /// Constructor.
  PreferencesFilter({
    required this.prefix,
    this.allowList,
  });

  /// A prefix to limit getting and clearing to only items that begin with
  /// this string.
  String prefix;

  /// A list of preference keys that will limit getting and clearing to only
  /// items included in this list.
  Set<String>? allowList;
}

/// Parameters for use in [getAll] methods.
class GetAllParameters {
  /// Constructor.
  GetAllParameters({required this.filter});

  /// Filter to limit which preferences are returned.
  PreferencesFilter filter;
}

/// Parameters for use in [clear] methods.
class ClearParameters {
  /// Constructor.
  ClearParameters({required this.filter});

  /// Filter to limit which preferences are cleared.
  PreferencesFilter filter;
}
