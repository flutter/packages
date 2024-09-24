// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// shared_preferences_async types.

import 'package:flutter/foundation.dart';

/// Basic options for creating SharedPreferencesAsync classes.
///
/// This class exists to provide extension to platform specific options as
/// there are currently no general options that are not platform specific.
@immutable
class SharedPreferencesOptions {
  /// Constructor for SharedPreferencesOptions.
  const SharedPreferencesOptions();
}

/// Filter options used to get and clear preferences on shared_preferences_async.
@immutable
class PreferencesFilters {
  /// Creates a new instance with the given options.
  const PreferencesFilters({
    this.allowList,
  });

  /// A list of preference keys that will limit getting and clearing to only
  /// items included in this list.
  ///
  /// An empty set will create a filter that allows no items to be set/get.
  final Set<String>? allowList;
}

/// Parameters for use in [get] methods on shared_preferences_async.
@immutable
class GetPreferencesParameters {
  /// Creates a new instance with the given options.
  const GetPreferencesParameters({required this.filter});

  /// Filter to limit which preferences are returned.
  final PreferencesFilters filter;
}

/// Parameters for use in [clear] methods on shared_preferences_async.
@immutable
class ClearPreferencesParameters {
  /// Creates a new instance with the given options.
  const ClearPreferencesParameters({required this.filter});

  /// Filter to limit which preferences are cleared.
  final PreferencesFilters filter;
}

//////////////////////////////////
// legacy_shared_preferences types.
//////////////////////////////////

/// Filter options used to get and clear preferences on legacy_shared_preferences.
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

/// Parameters for use in [getAll] methods on legacy_shared_preferences.
class GetAllParameters {
  /// Creates a new instance with the given options.
  GetAllParameters({required this.filter});

  /// Filter to limit which preferences are returned.
  PreferencesFilter filter;
}

/// Parameters for use in [clear] methods on legacy_shared_preferences.
class ClearParameters {
  /// Creates a new instance with the given options.
  ClearParameters({required this.filter});

  /// Filter to limit which preferences are cleared.
  PreferencesFilter filter;
}
