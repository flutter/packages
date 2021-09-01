// Copyright 2013 The Flutter Authors. All rights reserved.
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
///    Widgets text library and data files respectively.
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
library formats;

export 'dart/binary.dart';
export 'dart/model.dart';
export 'dart/text.dart';
