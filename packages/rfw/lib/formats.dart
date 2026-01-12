// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// # Remote Flutter Widgets - formats only import
///
/// This is a subset of the [rfw] library that only exposes features that
/// do not depend on Flutter.
///
/// Specifically, the following APIs are exposed by this library:
///
///  * [parseLibraryFile] and [parseDataFile], for parsing Remote Flutter
///    Widgets text library and data files respectively. (These are not exposed
///    by the [rfw] library since they are not intended for use in client-side
///    code.)
///
///  * [encodeLibraryBlob] and [encodeDataBlob], for encoding the output of the
///    previous methods into binary form.
///
///  * [decodeLibraryBlob] and [decodeDataBlob], which decode those binary
///    forms.
///
///  * The [DynamicMap], [DynamicList], and [BlobNode] types (and subclasses),
///    which are used to represent the data model and remote widget libraries in
///    memory.
///
/// For client-side code, import `package:rfw/rfw.dart` instead.
library formats;

export 'src/dart/binary.dart';
export 'src/dart/model.dart';
export 'src/dart/text.dart';
