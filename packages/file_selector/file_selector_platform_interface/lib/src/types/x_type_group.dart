// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/foundation.dart' show immutable;

/// A set of allowed XTypes.
@immutable
class XTypeGroup {
  /// Creates a new group with the given label and file extensions.
  ///
  /// A group with none of the type options provided indicates that any type is
  /// allowed.
  const XTypeGroup({
    this.label,
    List<String>? extensions,
    this.mimeTypes,
    this.uniformTypeIdentifiers,
    this.webWildCards,
  }) : _extensions = extensions;

  /// The 'name' or reference to this group of types.
  final String? label;

  /// The MIME types for this group.
  final List<String>? mimeTypes;

  /// The uniform type identifiers for this group
  final List<String>? uniformTypeIdentifiers;

  /// The web wild cards for this group (ex: image/*, video/*).
  final List<String>? webWildCards;

  final List<String>? _extensions;

  /// The extensions for this group.
  List<String>? get extensions {
    return _removeLeadingDots(_extensions);
  }

  /// Converts this object into a JSON formatted object.
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'label': label,
      'extensions': extensions,
      'mimeTypes': mimeTypes,
      'uniformTypeIdentifiers': uniformTypeIdentifiers,
      'webWildCards': webWildCards,
    };
  }

  /// True if this type group should allow any file.
  bool get allowsAny {
    return (extensions?.isEmpty ?? true) &&
        (mimeTypes?.isEmpty ?? true) &&
        (uniformTypeIdentifiers?.isEmpty ?? true) &&
        (webWildCards?.isEmpty ?? true);
  }

  static List<String>? _removeLeadingDots(List<String>? exts) =>
      exts?.map((String ext) => ext.startsWith('.') ? ext.substring(1) : ext).toList();
}
