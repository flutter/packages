import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// A class that holds reusable buffers for [web.VideoFrame] to CameraImageData
///  conversion to avoid unnecessary allocations
class VideoFrameBufferHolder {
  /// Creates a [VideoFrameBufferHolder] with the given parameters.
  /// [bufferSize] specifies the initial size of the buffer,
  /// and [format] specifies the format for copying video frames.
  VideoFrameBufferHolder({int bufferSize = 0, String format = 'RGBA'})
    : _currentBufferSize = bufferSize,
      copyOptions = web.VideoFrameCopyToOptions(format: format);

  int _currentBufferSize;

  /// The options used for copying video frames to the buffer,
  /// specifying the format as 'RGBA'.
  final web.VideoFrameCopyToOptions copyOptions;

  JSUint8Array? _reusableJSBuffer;

  Uint8List? _reusableDartView;

  /// The reusable JavaScript buffer used for frame conversion.
  JSUint8Array? get reusableJSBuffer => _reusableJSBuffer;

  /// The reusable Dart view of the current JavaScript buffer.
  Uint8List? get reusableDartView => _reusableDartView;

  /// Ensures that the reusable buffer is of the required size.
  /// If the current buffer is null or its size does not match the required
  /// size, a new buffer is allocated and the corresponding Dart view is updated.
  void ensureBufferSize(int requiredSize) {
    if (_currentBufferSize == requiredSize && _reusableJSBuffer != null) {
      return;
    }

    _currentBufferSize = requiredSize;

    final jsBuffer = JSArrayBuffer(requiredSize);
    _reusableJSBuffer = JSUint8Array(jsBuffer, 0, requiredSize);

    _reusableDartView = _reusableJSBuffer!.toDart;
  }

  /// Disposes of the reusable buffers.
  /// This method should be called when the buffers are no longer needed
  void dispose() {
    _currentBufferSize = 0;
    _reusableJSBuffer = null;
    _reusableDartView = null;
  }
}
