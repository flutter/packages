// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'geometry/image.dart';
import 'geometry/path.dart';
import 'geometry/pattern.dart';
import 'geometry/vertices.dart';
import 'paint.dart';
import 'util.dart';

/// An immutable collection of vector instructions, with [width] and [height]
/// specifying the viewport coordinates.
@immutable
class VectorInstructions {
  /// Creates a new set of [VectorInstructions].
  ///
  /// The combined lengths of [paths] and [vertices] must be greater than 0.
  const VectorInstructions({
    required this.width,
    required this.height,
    required this.paints,
    this.paths = const <Path>[],
    this.vertices = const <IndexedVertices>[],
    this.text = const <TextConfig>[],
    this.images = const <ImageData>[],
    this.drawImages = const <DrawImageData>[],
    this.patternData = const <PatternData>[],
    this.textPositions = const <TextPosition>[],
    required this.commands,
  });

  /// The extent of the viewport on the x axis.
  final double width;

  /// The extent of the viewport on the y axis.
  final double height;

  /// The [Paint] objects used in [commands].
  final List<Paint> paints;

  /// The [Path] objects, if any, used in [commands].
  final List<Path> paths;

  /// The [IndexedVertices] objects, if any, used in [commands].
  final List<IndexedVertices> vertices;

  /// The [TextConfig] objects, if any, used in [commands].
  final List<TextConfig> text;

  /// The [ImageData] objects, if any, used in [commands].
  final List<ImageData> images;

  /// The [DrawImageData] objects, if any, used in [commands].
  final List<DrawImageData> drawImages;

  /// The pattern data objects, if any used in [commands].
  final List<PatternData> patternData;

  /// A list of text position advances, if any, used in [commands].
  final List<TextPosition> textPositions;

  /// The painting order list of drawing commands.
  ///
  /// If the command type is [DrawCommandType.path], this command specifies
  /// drawing with [paths]. If it is [DrawCommandType.vertices], this command
  /// specifies drawing with [vertices].
  ///
  /// If drawing using vertices, the [Paint.stroke] property is ignored.
  final List<DrawCommand> commands;

  @override
  int get hashCode => Object.hash(
      width,
      height,
      Object.hashAll(patternData),
      Object.hashAll(paints),
      Object.hashAll(paths),
      Object.hashAll(vertices),
      Object.hashAll(text),
      Object.hashAll(commands),
      Object.hashAll(images),
      Object.hashAll(drawImages),
      Object.hashAll(textPositions));

  @override
  bool operator ==(Object other) {
    return other is VectorInstructions &&
        other.width == width &&
        other.height == height &&
        listEquals(other.patternData, patternData) &&
        listEquals(other.paints, paints) &&
        listEquals(other.paths, paths) &&
        listEquals(other.vertices, vertices) &&
        listEquals(other.text, text) &&
        listEquals(other.commands, commands) &&
        listEquals(other.images, images) &&
        listEquals(other.drawImages, drawImages) &&
        listEquals(other.textPositions, textPositions);
  }

  @override
  String toString() => 'VectorInstructions($width, $height)';
}

/// The drawing mode of a [DrawCommand].
///
/// See [DrawCommand.type] and [VectorInstructions.commands].
enum DrawCommandType {
  /// Specifies that this command draws a [Path].
  path,

  /// Specifies that this command draws an [IndexedVertices] object.
  ///
  /// In this case, any [Stroke] properties on the [Paint] are ignored.
  vertices,

  /// Specifies that this command saves a layer.
  ///
  /// In this case, any [Stroke] properties on the [Paint] are ignored.
  saveLayer,

  /// Specifies that this command restores a layer.
  ///
  /// In this case, both the objectId and paintId will be `null`.
  restore,

  /// Specifies that this command adds a clip to the stack.
  ///
  /// In this case, the objectId will be for a path, and the paint id will be
  /// `null`.
  clip,

  /// Specifies that this command adds a mask to the stack.
  ///
  /// Implementations should save a layer using a grey scale color matrix.
  mask,

  /// Specifies that this command draws text.
  text,

  /// Specifies that this command draws an image.
  image,

  /// Specifies that this command draws a pattern.
  pattern,

  /// Specifies an adjustment to the current text position.
  textPosition,
}

/// A drawing command combining the index of a [Path] or an [IndexedVertices]
/// with a [Paint].
///
/// The type of object is specified by [type].
///
/// The debug string property is some identifier, possibly from the source SVG,
/// identifying an original source for this information.
@immutable
class DrawCommand {
  /// Creates a new canvas drawing operation.
  ///
  /// See [DrawCommand].
  const DrawCommand(
    this.type, {
    this.objectId,
    this.paintId,
    this.debugString,
    this.patternId,
    this.patternDataId,
  });

  /// A string, possibly from the original source SVG file, identifying a source
  /// for this command.
  final String? debugString;

  /// Whether [objectId] points to a [Path] or a [IndexedVertices] object in
  /// [VectorInstructions].
  final DrawCommandType type;

  /// The path or vertices object index in [VectorInstructions.paths] or
  /// [VectorInstructions.vertices].
  ///
  /// A value of `null` indicates that there is no object associated with
  /// this command.
  ///
  /// Use [type] to determine which type of object this is.
  final int? objectId;

  /// The index of a [Paint] for this object in [VectorInstructions.paints].
  ///
  /// A value of `null` indicates that there is no paint object associated with
  /// this command.
  final int? paintId;

  /// The index of a pattern for this object in [VectorInstructions.patterns].
  final int? patternId;

  /// The index of a pattern configuration for this object in
  /// [VectorInstructions.patternData].
  final int? patternDataId;

  @override
  int get hashCode => Object.hash(type, objectId, paintId, debugString);

  @override
  bool operator ==(Object other) {
    return other is DrawCommand &&
        other.type == type &&
        other.objectId == objectId &&
        other.paintId == paintId;
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('DrawCommand($type');
    if (objectId != null) {
      buffer.write(', objectId: $objectId');
    }
    if (paintId != null) {
      buffer.write(', paintId: $paintId');
    }
    if (debugString != null) {
      buffer.write(", debugString: '$debugString'");
    }
    if (patternId != null) {
      buffer.write(', patternId: $patternId');
    }
    if (patternDataId != null) {
      buffer.write(', patternDataId: $patternDataId');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
