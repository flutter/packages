// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

/// Create anchor element with download attribute
HTMLAnchorElement createAnchorElement(String href, String? suggestedName) =>
    (document.createElement('a') as HTMLAnchorElement)
      ..href = href
      ..download = suggestedName ?? 'download'
      ..rel = 'noreferrer';

/// Add an element to a container and click it
void addElementToContainerAndClick(Element container, HTMLElement element) {
  // Add the element and click it
  // All previous elements will be removed before adding the new one
  container.appendChild(element);
  element.click();
}

/// Initializes a DOM container where elements can be injected.
Element ensureInitialized(String id) {
  Element? target = document.querySelector('#$id');
  if (target == null) {
    final Element targetElement = document.createElement('flt-x-file')..id = id;

    document.body!.appendChild(targetElement);
    target = targetElement;
  }
  return target;
}

/// Prompts a "Save as..." dialog in the browser for the contents of [blob].
///
/// Uses [name] as a *suggestion* for the saved filename, but users can rename
/// the file to whatever they want before actually saving it.
///
/// Maybe some day: https://developer.mozilla.org/en-US/docs/Web/API/Window/showSaveFilePicker
Future<void> downloadBlob(Blob blob, String? name) async {
  // Create a DOM container where the anchor can be injected.
  final Element target = ensureInitialized('__x_file_dom_element');
  final String objectURL = URL.createObjectURL(blob);
  // Create an <a> tag with the appropriate download attributes and click it
  final HTMLAnchorElement element = createAnchorElement(objectURL, name);
  // TODO(dit): Is there a better way to revoke the URL that we're creating?
  Future<void>.delayed(const Duration(minutes: 5), () {
    // Is this the industry standard?
    // See: https://github.com/eligrey/FileSaver.js/blob/cea522bc41bfadc364837293d0c4dc585a65ac46/src/FileSaver.js#L163
    URL.revokeObjectURL(objectURL);
  });
  // Clear the children in target.
  target.replaceChildren(JSArray<JSAny?>());
  // Add the new `element` and click.
  addElementToContainerAndClick(target, element);
}

/// Converts a [Blob] to [Uint8List] through a [FileReader].
Future<Uint8List> blobToBytes(Blob blob) async {
  final FileReader reader = FileReader();
  reader.readAsArrayBuffer(blob);
  await reader.onLoadEnd.first;

  final Uint8List? result =
      (reader.result as JSArrayBuffer?)?.toDart.asUint8List();
  if (result == null) {
    throw StateError('Cannot read bytes from Blob. Is it still available?');
  }

  return result;
}

/// Converts a bunch of [bytes] into a [Blob] and an optional [mimeType].
Blob bytesToBlob(Uint8List bytes, String? mimeType) {
  return Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    BlobPropertyBag(type: mimeType ?? ''),
  );
}

/// Retrieves a [Blob] by its [objectUrl].
Future<Blob> fetchBlob(String objectUrl) async {
  try {
    final Response response = await window.fetch(objectUrl.toJS).toDart;
    return response.blob().toDart;
  } catch (e) {
    throw StateError('Could not fetch Blob by URL: $objectUrl');
  }
}
