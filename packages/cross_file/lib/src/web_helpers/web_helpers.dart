// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:web/web.dart';
import '../types/html.dart';

/// Type definition for function that creates anchor elements
typedef CreateAnchorElement =
    HTMLAnchorElement Function(String href, String? suggestedName);

/// Override for creating anchor elements for testing purposes
CreateAnchorElement? anchorElementOverride;

/// Create anchor element with download attribute
HTMLAnchorElement createAnchorElement(String href, String? suggestedName) =>
    (document.createElement('a') as HTMLAnchorElement)
      ..href = href
      ..download = suggestedName ?? 'download';

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

/// Determines if the browser is Safari from its vendor string.
/// (This is the same check used in flutter/engine)
bool isSafari() {
  return window.navigator.vendor == 'Apple Computer, Inc.';
}

/// Saves the given [XFile] to user's device ("Save As" dialog).
Future<void> saveFileAs(XFile file, String path) async {
  // Create container element.
  final Element target = ensureInitialized('__x_file_dom_element');

  // Create <a> element.
  final HTMLAnchorElement element =
      anchorElementOverride != null
          ? anchorElementOverride!(file.path, file.name)
          : createAnchorElement(file.path, file.name);

  // Clear existing children before appending new one.
  while (target.children.length > 0) {
    target.removeChild(target.children.item(0)!);
  }

  // Add and click.
  addElementToContainerAndClick(target, element);
}
