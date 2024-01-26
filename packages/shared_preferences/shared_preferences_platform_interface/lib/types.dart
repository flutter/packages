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
class PreferencesFilters {
  /// Creates a new instance with the given options.
  const PreferencesFilters({
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
  final PreferencesFilters filter;
}

/// Parameters for use in [clear] methods.
class ClearPreferencesParameters {
  /// Creates a new instance with the given options.
  const ClearPreferencesParameters({required this.filter});

  /// Filter to limit which preferences are cleared.
  final PreferencesFilters filter;
}

// ALL CLASSES BELOW HERE ARE DEPRECATED AND SHOULD NOT BE USED.

/// Filter options used to get and clear preferences.
///
/// Deprecated in favor of [PreferencesFilters].
class PreferencesFilter {
  /// Creates a new instance with the given options.
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
///
/// Deprecated in favor of [GetPreferencesParameters].
class GetAllParameters {
  /// Creates a new instance with the given options.
  GetAllParameters({required this.filter});

  /// Filter to limit which preferences are returned.
  PreferencesFilter filter;
}

/// Parameters for use in [clear] methods.
///
/// Deprecated in favor of [ClearPreferencesParameters].
class ClearParameters {
  /// Creates a new instance with the given options.
  ClearParameters({required this.filter});

  /// Filter to limit which preferences are cleared.
  PreferencesFilter filter;
}
