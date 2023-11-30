// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';

import 'web_helpers.dart';

/// The maximum size of each chunk.
///
/// (Currently set to 25MB)
const int MAX_CHUNK_SIZE = 25 * 1024 * 1024;

/// This class streams an [html.Blob] in chunks of [MAX_CHUNK_SIZE] bytes.
class BlobStream extends Stream<Uint8List> {
  /// Constructs the byte stream.
  ///
  /// If passed, [start] will be used as the first byte to read, and [end]
  /// will be the last. If not set, the [blob] will be read in its entirety.
  BlobStream(Future<html.Blob> blob, [int? start, int? end])
      : _blob = blob,
        _nextByte = start ?? 0,
        _finalByte = end;

  // The source of data that we want to Stream
  final Future<html.Blob> _blob;

  // The byte that will be read next.
  int _nextByte;
  // The last byte that will be read (if passed).
  final int? _finalByte;

  // The StreamController that underpins this class.
  late StreamController<Uint8List> _controller;

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    _controller = StreamController<Uint8List>(
      onListen: _readChunk,
    );
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  // Reads [_blockSize] bytes from [_currentPosition] from [_blob].
  Future<void> _readChunk() async {
    final int chunkSize = _getNextChunkSize(_nextByte, end: _finalByte);
    assert(chunkSize >= 0);

    return _blob
        .then((html.Blob blob) => blob.slice(_nextByte, _nextByte + chunkSize))
        .then(blobToByteBuffer)
        .then(_broadcastBytes)
        .then((int bytes) {
      // Computes if the blob has been fully read.
      // Move the internal [_nextByte] pointer by [bytes].
      _nextByte += bytes;
      // The blob is fully read when _nextByte is _finalByte, or
      // when readBytes is smaller than CHUNK_SIZE.
      return (bytes < MAX_CHUNK_SIZE) || (_nextByte == _finalByte);
    }).then((bool done) => !done ? _readChunk() : _doneReading());
  }

  // Sends the bytes through the stream, and returns how many bytes were sent.
  int _broadcastBytes(Uint8List bytes) {
    _controller.add(bytes);
    return bytes.lengthInBytes;
  }

  // Cleanup when the stream is done.
  Future<void> _doneReading() {
    return _controller.close();
  }

  // Returns the size in bytes of the next chunk.
  //
  // When [end] is not passed, this always returns [max] (which defaults to
  // [CHUNK_SIZE]).
  //
  // When `end` **is** passed, this returns either the remaining
  // bytes to read (`end - start`), or `max`, whatever is **smaller**.
  int _getNextChunkSize(int start, {int max = MAX_CHUNK_SIZE, int? end}) {
    return (end == null) ? max : min(max, end - start);
  }
}
