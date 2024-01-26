// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Basic options for creating SharedPreferences classes.
///
/// This class exists to provide extension to platform specific options as
/// there are currently no general options that are not platform specific.
class SharedPreferencesOptions {
  /// Constructor for SharedPreferencesOptions.
  const SharedPreferencesOptions();
}

/// Filter options used to get and clear preferences.
class PreferencesFilter {
  /// Creates a new instance with the given options.
  const PreferencesFilter({
    this.allowList,
  });

  /// A list of preference keys that will limit getting and clearing to only
  /// items included in this list.
  final Set<String>? allowList;
}

/// Parameters for use in [get] methods.
class GetPreferencesParameters {
  /// Creates a new instance with the given options.
  const GetPreferencesParameters({required this.filter});

  /// Filter to limit which preferences are returned.
  final PreferencesFilter filter;
}

/// Parameters for use in [clear] methods.
class ClearParameters {
  /// Creates a new instance with the given options.
  const ClearParameters({required this.filter});

  /// Filter to limit which preferences are cleared.
  final PreferencesFilter filter;
}
