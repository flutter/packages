import 'package:flutter/foundation.dart';

/// Describes a single level in a building.
///
/// Multiple buildings can share a level - in this case the level instances will compare as equal,
/// even though the level numbers/names may be different.
@immutable
class IndoorLevel {
  /// Creates a immutable representation of a [GoogleMap] indoor level.
  const IndoorLevel({this.name, this.shortName});

  /// Localized display name for the level, e.g. "Ground floor".
  final String? name;

  /// Localized short display name for the level, e.g. "1".
  final String? shortName;

  /// Initialize an IndoorLevel from a map.
  static IndoorLevel? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> map = json as Map<String, dynamic>;
    return IndoorLevel(
        name: map['name'] as String?, shortName: map['shortName'] as String?);
  }
}
