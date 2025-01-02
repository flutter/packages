// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'geometry/image.dart';
import 'geometry/matrix.dart';
import 'geometry/path.dart';
import 'geometry/pattern.dart';
import 'geometry/vertices.dart';
import 'paint.dart';
import 'svg/resolver.dart';
import 'vector_instructions.dart';

/// An interface for building up a stack of vector commands.
class DrawCommandBuilder {
  final Map<Paint, int> _paints = <Paint, int>{};
  final Map<Path, int> _paths = <Path, int>{};
  final Map<TextConfig, int> _text = <TextConfig, int>{};
  final Map<ImageData, int> _images = <ImageData, int>{};
  final Map<DrawImageData, int> _drawImages = <DrawImageData, int>{};
  final Map<IndexedVertices, int> _vertices = <IndexedVertices, int>{};
  final List<DrawCommand> _commands = <DrawCommand>[];
  final Map<Object, int> _patterns = <Object, int>{};
  final Map<PatternData, int> _patternData = <PatternData, int>{};
  final Map<TextPosition, int> _textPositions = <TextPosition, int>{};

  int _getOrGenerateId<T>(T object, Map<T, int> map) =>
      map.putIfAbsent(object, () => map.length);

  /// Add a vertices to the command stack.
  void addVertices(IndexedVertices vertices, Paint paint) {
    final int paintId = _getOrGenerateId(paint, _paints);
    final int verticesId = _getOrGenerateId(vertices, _vertices);
    _commands.add(DrawCommand(
      DrawCommandType.vertices,
      paintId: paintId,
      objectId: verticesId,
    ));
  }

  /// Add a save layer to the command stack.
  void addSaveLayer(Paint paint) {
    final int paintId = _getOrGenerateId(paint, _paints);
    _commands.add(DrawCommand(
      DrawCommandType.saveLayer,
      paintId: paintId,
    ));
  }

  /// Add a restore to the command stack.
  void restore() {
    _commands.add(const DrawCommand(DrawCommandType.restore));
  }

  /// Adds a clip to the command stack.
  void addClip(Path path) {
    final int pathId = _getOrGenerateId(path, _paths);
    _commands.add(DrawCommand(DrawCommandType.clip, objectId: pathId));
  }

  /// Adds a mask to the command stack.
  void addMask() {
    _commands.add(const DrawCommand(DrawCommandType.mask));
  }

  /// Adds a pattern to the command stack.
  void addPattern(
    Object id, {
    required double x,
    required double y,
    required double width,
    required double height,
    required AffineMatrix transform,
  }) {
    final int patternId = _getOrGenerateId(id, _patterns);
    final int patternDataId = _getOrGenerateId(
      PatternData(x, y, width, height, transform),
      _patternData,
    );
    _commands.add(DrawCommand(
      DrawCommandType.pattern,
      objectId: patternId,
      patternDataId: patternDataId,
    ));
  }

  /// Updates the current text position to [position].
  void updateTextPosition(TextPosition position) {
    final int positionId = _getOrGenerateId(position, _textPositions);
    _commands.add(DrawCommand(
      DrawCommandType.textPosition,
      objectId: positionId,
    ));
  }

  /// Add a path to the current draw command stack
  void addPath(Path path, Paint paint, String? debugString, Object? patternId) {
    if (path.isEmpty) {
      return;
    }
    final int pathId = _getOrGenerateId(path, _paths);
    final int paintId = _getOrGenerateId(paint, _paints);

    _commands.add(DrawCommand(DrawCommandType.path,
        objectId: pathId,
        paintId: paintId,
        debugString: debugString,
        patternId: patternId != null ? _patterns[patternId] : null));
  }

  /// Adds a text to the current draw command stack.
  void addText(
    TextConfig textConfig,
    Paint paint,
    String? debugString,
    Object? patternId,
  ) {
    final int paintId = _getOrGenerateId(paint, _paints);
    final int styleId = _getOrGenerateId(textConfig, _text);
    _commands.add(DrawCommand(
      DrawCommandType.text,
      objectId: styleId,
      paintId: paintId,
      debugString: debugString,
      patternId: patternId != null ? _patterns[patternId] : null,
      patternDataId: patternId != null ? _patternData[patternId] : null,
    ));
  }

  /// Add an image to the current draw command stack.
  void addImage(ResolvedImageNode node, String? debugString) {
    final ImageData imageData = ImageData(node.data, node.format.index);
    final int imageId = _getOrGenerateId(imageData, _images);
    final DrawImageData drawImageData = DrawImageData(
      imageId,
      node.rect,
      node.transform,
    );

    final int drawImageId = _getOrGenerateId(drawImageData, _drawImages);
    _commands.add(DrawCommand(
      DrawCommandType.image,
      objectId: drawImageId,
      debugString: debugString,
    ));
  }

  /// Create a new [VectorInstructions] with the given width and height.
  VectorInstructions toInstructions(double width, double height) {
    return VectorInstructions(
      width: width,
      height: height,
      paints: _paints.keys.toList(),
      paths: _paths.keys.toList(),
      text: _text.keys.toList(),
      vertices: _vertices.keys.toList(),
      images: _images.keys.toList(),
      drawImages: _drawImages.keys.toList(),
      commands: _commands,
      patternData: _patternData.keys.toList(),
      textPositions: _textPositions.keys.toList(),
    );
  }
}
