// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:web/web.dart';

/// Class to manipulate the DOM with the intention of reading files from it.
class DomHelper {
  /// Default constructor, initializes the container DOM element.
  DomHelper() {
    final Element body = document.querySelector('body')!;
    body.appendChild(_container);
  }

  final Element _container = document.createElement('file-selector');

  /// Sets the <input /> attributes and waits for a file to be selected.
  Future<List<XFile>> getFiles({
    String accept = '',
    bool multiple = false,
    @visibleForTesting HTMLInputElement? input,
  }) {
    final Completer<List<XFile>> completer = Completer<List<XFile>>();
    final HTMLInputElement inputElement =
        input ?? (document.createElement('input') as HTMLInputElement)
          ..type = 'file';

    _container.appendChild(
      inputElement
        ..accept = accept
        ..multiple = multiple,
    );

    inputElement.onChange.first.then((_) {
      final List<XFile> files = Iterable<File>.generate(
              inputElement.files!.length,
              (int i) => inputElement.files!.item(i)!)
          .map(_convertFileToXFile)
          .toList();
      inputElement.remove();
      completer.complete(files);
    });

    inputElement.onError.first.then((Event event) {
      final ErrorEvent error = event as ErrorEvent;
      final PlatformException platformException = PlatformException(
        code: error.type,
        message: error.message,
      );
      inputElement.remove();
      completer.completeError(platformException);
    });

    inputElement.addEventListener(
      'cancel',
      (Event event) {
        inputElement.remove();
        completer.complete(<XFile>[]);
      }.toJS,
    );

    // TODO(dit): Reimplement this with the showPicker() API, https://github.com/flutter/flutter/issues/130365
    inputElement.click();

    return completer.future;
  }

  XFile _convertFileToXFile(File file) => XFile(
        URL.createObjectURL(file),
        name: file.name,
        length: file.size,
        lastModified: DateTime.fromMillisecondsSinceEpoch(file.lastModified),
      );
}
