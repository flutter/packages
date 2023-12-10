// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

/// An HTMLElementView widget that resizes with its contents.
class FlexHtmlElementView extends StatefulWidget {
  /// Constructor
  const FlexHtmlElementView({
    super.key,
    required this.viewType,
    this.onPlatformViewCreated,
    this.initialSize,
  });

  /// See [HtmlElementView.viewType].
  final String viewType;

  /// See [HtmlElementView.onPlatformViewCreated].
  final PlatformViewCreatedCallback? onPlatformViewCreated;

  /// The initial Size for the widget, before it starts tracking its contents.
  final Size? initialSize;

  @override
  State<StatefulWidget> createState() => _FlexHtmlElementView();
}

class _FlexHtmlElementView extends State<FlexHtmlElementView> {
  /// The last measured size of the watched element.
  Size? _lastReportedSize;

  /// Watches for changes being made to the DOM tree.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver
  web.MutationObserver? _mutationObserver;

  /// Reports changes to the dimensions of an Element's content box.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Resize_Observer_API
  web.ResizeObserver? _resizeObserver;

  @override
  void dispose() {
    // Disconnect the observers
    _mutationObserver?.disconnect();
    _resizeObserver?.disconnect();
    super.dispose();
  }

  /// Update the state with the new `size`, if needed.
  void _doResize(Size size) {
    if (size != _lastReportedSize) {
      final String log = <Object?>[
        'Resizing: ',
        widget.viewType,
        size.width,
        size.height
      ].join(' ');
      web.console.debug(log.toJS);
      setState(() {
        _lastReportedSize = size;
      });
    }
  }

  /// The function called whenever an observed resize occurs.
  void _onResizeEntries(
    JSArray resizes,
    web.ResizeObserver observer,
  ) {
    final web.DOMRectReadOnly rect =
        resizes.toDart.cast<web.ResizeObserverEntry>().last.contentRect;
    if (rect.width > 0 && rect.height > 0) {
      _doResize(Size(rect.width.toDouble(), rect.height.toDouble()));
    }
  }

  /// A function which will be called on each DOM change that qualifies given the observed node and options.
  ///
  /// When mutations are received, this function attaches a Resize Observer to
  /// the first child of the mutation, which will drive
  void _onMutationRecords(
    JSArray mutations,
    web.MutationObserver observer,
  ) {
    mutations.toDart
        .cast<web.MutationRecord>()
        .forEach((web.MutationRecord mutation) {
      if (mutation.addedNodes.length > 0) {
        final web.Element? element = _locateSizeProvider(mutation.addedNodes);
        if (element != null) {
          _resizeObserver = web.ResizeObserver(_onResizeEntries.toJS);
          _resizeObserver?.observe(element);
          // Stop looking at other mutations
          observer.disconnect();
          return;
        }
      }
    });
  }

  /// Registers a MutationObserver on the root element of the HtmlElementView.
  void _registerListeners(web.Element? root) {
    assert(root != null, 'DOM is not ready for the FlexHtmlElementView');
    _mutationObserver = web.MutationObserver(_onMutationRecords.toJS);
    // Monitor the size of the child element, whenever it's created...
    _mutationObserver!.observe(
      root!,
      web.MutationObserverInit(
        childList: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: _lastReportedSize ?? widget.initialSize ?? const Size(1, 1),
      child: HtmlElementView(
          viewType: widget.viewType,
          onPlatformViewCreated: (int viewId) async {
            _registerListeners(_locatePlatformViewRoot(viewId));
            if (widget.onPlatformViewCreated != null) {
              widget.onPlatformViewCreated!(viewId);
            }
          }),
    );
  }
}

/// Locates which of the elements will act as the size provider.
///
/// The `elements` list should contain a single element: the only child of the
/// element returned by `_locatePlatformViewRoot`.
web.Element? _locateSizeProvider(web.NodeList elements) {
  return elements.item(0) as web.Element?;
}

/// Finds the root element of a platform view by its `viewId`.
///
/// This element matches the one returned by the registered platform view factory.
web.Element? _locatePlatformViewRoot(int viewId) {
  return web.document
      .querySelector('flt-platform-view[slot\$="-$viewId"] :first-child');
}
