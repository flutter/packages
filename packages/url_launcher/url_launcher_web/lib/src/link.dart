// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web/web.dart' as html;

/// The unique identifier for the view type to be used for link platform views.
const String linkViewType = '__url_launcher::link';

/// The name of the property used to set the viewId on the DOM element.
const String linkViewIdProperty = '__url_launcher::link::viewId';

/// Signature for a function that takes a unique [id] and creates an HTML element.
typedef HtmlViewFactory = html.Element Function(int viewId);

/// Factory that returns the link DOM element for each unique view id.
HtmlViewFactory get linkViewFactory => LinkViewController._viewFactory;

/// The delegate for building the [Link] widget on the web.
///
/// It uses a platform view to render an anchor element in the DOM.
class WebLinkDelegate extends StatefulWidget {
  /// Creates a delegate for the given [link].
  const WebLinkDelegate(this.link, {super.key});

  /// Information about the link built by the app.
  final LinkInfo link;

  @override
  WebLinkDelegateState createState() => WebLinkDelegateState();
}

/// The link delegate used on the web platform.
///
/// For external URIs, it lets the browser do its thing. For app route names, it
/// pushes the route name to the framework.
class WebLinkDelegateState extends State<WebLinkDelegate> {
  late LinkViewController _controller;

  @override
  void didUpdateWidget(WebLinkDelegate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.link.uri != oldWidget.link.uri) {
      _controller.setUri(widget.link.uri);
    }
    if (widget.link.target != oldWidget.link.target) {
      _controller.setTarget(widget.link.target);
    }
  }

  Future<void> _followLink() {
    LinkViewController.registerHitTest(_controller);
    return Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.link.builder(
          context,
          widget.link.isDisabled ? null : _followLink,
        ),
        Positioned.fill(
          child: PlatformViewLink(
            viewType: linkViewType,
            onCreatePlatformView: (PlatformViewCreationParams params) {
              _controller = LinkViewController.fromParams(params);
              return _controller
                ..setUri(widget.link.uri)
                ..setTarget(widget.link.target);
            },
            surfaceFactory:
                (BuildContext context, PlatformViewController controller) {
              return PlatformViewSurface(
                controller: controller,
                gestureRecognizers: const <Factory<
                    OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.transparent,
              );
            },
          ),
        ),
      ],
    );
  }
}

final JSAny _useCapture = <String, Object>{'capture': true}.jsify()!;

/// Controls link views.
class LinkViewController extends PlatformViewController {
  /// Creates a [LinkViewController] instance with the unique [viewId].
  LinkViewController(this.viewId) {
    if (_instances.isEmpty) {
      // This is the first controller being created, attach the global click
      // listener.

      // Why listen in the capture phase?
      //
      // To ensure we always receive the event even if the engine calls
      // `stopPropagation`.
      html.window
          .addEventListener('keydown', _jsGlobalKeydownListener, _useCapture);
      html.window.addEventListener('click', _jsGlobalClickListener);
    }
    _instances[viewId] = this;
  }

  /// Creates and initializes a [LinkViewController] instance with the given
  /// platform view [params].
  factory LinkViewController.fromParams(
    PlatformViewCreationParams params,
  ) {
    final int viewId = params.id;
    final LinkViewController controller = LinkViewController(viewId);
    controller._initialize().then((_) {
      /// Because _initialize is async, it can happen that [LinkViewController.dispose]
      /// may get called before this `then` callback.
      /// Check that the `controller` that was created by this factory is not
      /// disposed before calling `onPlatformViewCreated`.
      if (_instances[viewId] == controller) {
        params.onPlatformViewCreated(viewId);
      }
    });
    return controller;
  }

  static final Map<int, LinkViewController> _instances =
      <int, LinkViewController>{};

  static html.Element _viewFactory(int viewId) {
    return _instances[viewId]!._element;
  }

  static int? _hitTestedViewId;

  static final JSFunction _jsGlobalKeydownListener = _onGlobalKeydown.toJS;
  static final JSFunction _jsGlobalClickListener = _onGlobalClick.toJS;

  static void _onGlobalKeydown(html.KeyboardEvent event) {
    // Why not use `event.target`?
    //
    // Because the target is usually <flutter-view> and not the <a> element, so
    // it's not very helpful. That's because focus management is handled by
    // Flutter, and the browser doesn't always know which element is focused. In
    // fact, in many cases, the focused widget is fully drawn on canvas and
    // there's no corresponding HTML element to receive browser focus.

    // Why not check for "Enter" or "Space" keys?
    //
    // Because we don't know (nor do we want to assume) which keys the app
    // considers to be "trigger" keys. So we let the app do its thing, and if it
    // decides to "trigger" the link, it will call `followLink`, which will set
    // `_hitTestedViewId` to the ID of the triggered Link.

    // Life of a keydown event:
    //
    // For simplicity, let's assume we are dealing with a Link widget setup with
    // with a button widget like this:
    //
    // ```dart
    // Link(
    //   uri: Uri.parse('...'),
    //   builder: (context, followLink) {
    //     return ElevatedButton(
    //       onPressed: followLink,
    //       child: const Text('Press me'),
    //     );
    //   },
    // );
    // ```
    //
    // 1. The user navigates through the UI using the Tab key until they reach
    //    the button in question.
    // 2. The user presses the Enter key to trigger the link.
    // 3. The framework receives the Enter keydown event:
    //    - The event is dispatched to the button widget.
    //    - The button widget calls `onPressed` and therefor `followLink`.
    //    - `followLink` calls `LinkViewController.registerHitTest`.
    //    - `LinkViewController.registerHitTest` sets `_hitTestedViewId`.
    // 4. The `LinkViewController` also receives the keydown event:
    //    - We check the value of `_hitTestedViewId`.
    //    - If `_hitTestedViewId` is set, it means the app triggered the link.
    //    - We navigate to the Link's URI.

    // The keydown event is not directly associated with the target Link, so
    // we need to look for the recently hit tested Link to handle the event.
    if (_hitTestedViewId != null) {
      _instances[_hitTestedViewId]?._onDomKeydown();
    }
    // After the keyboard event has been received, clean up the hit test state
    // so we can start fresh on the next event.
    unregisterHitTest();
  }

  static void _onGlobalClick(html.MouseEvent event) {
    final int? viewId = getViewIdFromTarget(event);
    _instances[viewId]?._onDomClick(event);
    // After the DOM click event has been received, clean up the hit test state
    // so we can start fresh on the next event.
    unregisterHitTest();
  }

  /// Call this method to indicate that a hit test has been registered for the
  /// given [controller].
  ///
  /// The [onClick] callback is invoked when the anchor element receives a
  /// `click` from the browser.
  static void registerHitTest(LinkViewController controller) {
    _hitTestedViewId = controller.viewId;
  }

  /// Removes all information about previously registered hit tests.
  static void unregisterHitTest() {
    _hitTestedViewId = null;
  }

  @override
  final int viewId;

  late html.HTMLElement _element;

  Future<void> _initialize() async {
    _element = html.document.createElement('a') as html.HTMLElement;
    _element[linkViewIdProperty] = viewId.toJS;
    _element.style
      ..opacity = '0'
      ..display = 'block'
      ..width = '100%'
      ..height = '100%'
      ..cursor = 'unset';

    // This is recommended on MDN:
    // - https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a#attr-target
    _element.setAttribute('rel', 'noreferrer noopener');

    final Map<String, dynamic> args = <String, dynamic>{
      'id': viewId,
      'viewType': linkViewType,
    };
    await SystemChannels.platform_views.invokeMethod<void>('create', args);
  }

  void _onDomKeydown() {
    assert(
      _hitTestedViewId == viewId,
      'Keydown event should only be handled by the hit tested Link',
    );

    if (_isExternalLink) {
      // External links are not handled by the browser when triggered via a
      // keydown, so we have to launch the url manually.
      UrlLauncherPlatform.instance
          .launchUrl(_uri.toString(), const LaunchOptions());
      return;
    }

    // A uri that doesn't have a scheme is an internal route name. In this
    // case, we push it via Flutter's navigation system instead of using
    // `launchUrl`.
    final String routeName = _uri.toString();
    pushRouteNameToFramework(null, routeName);
  }

  void _onDomClick(html.MouseEvent event) {
    final bool isHitTested = _hitTestedViewId == viewId;
    if (!isHitTested) {
      // There was no hit test registered for this click. This means the click
      // landed on the anchor element but not on the underlying widget. In this
      // case, we prevent the browser from following the click.
      event.preventDefault();
      return;
    }

    if (_isExternalLink) {
      // External links will be handled by the browser, so we don't have to do
      // anything.
      return;
    }

    // A uri that doesn't have a scheme is an internal route name. In this
    // case, we push it via Flutter's navigation system instead of letting the
    // browser handle it.
    event.preventDefault();
    final String routeName = _uri.toString();
    pushRouteNameToFramework(null, routeName);
  }

  Uri? _uri;
  bool get _isExternalLink => _uri != null && _uri!.hasScheme;

  /// Set the [Uri] value for this link.
  ///
  /// When Uri is null, the `href` attribute of the link is removed.
  void setUri(Uri? uri) {
    _uri = uri;
    if (uri == null) {
      _element.removeAttribute('href');
    } else {
      String href = uri.toString();
      // in case an internal uri is given, the url mus be properly encoded
      // using the currently used [UrlStrategy]
      if (!uri.hasScheme) {
        href = ui_web.urlStrategy?.prepareExternalUrl(href) ?? href;
      }
      _element.setAttribute('href', href);
    }
  }

  /// Set the [LinkTarget] value for this link.
  void setTarget(LinkTarget target) {
    _element.setAttribute('target', _getHtmlTarget(target));
  }

  String _getHtmlTarget(LinkTarget target) {
    switch (target) {
      case LinkTarget.defaultTarget:
      case LinkTarget.self:
        return '_self';
      case LinkTarget.blank:
        return '_blank';
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    return '_self';
  }

  @override
  Future<void> clearFocus() async {
    // Currently this does nothing on Flutter Web.
    // TODO(het): Implement this. See https://github.com/flutter/flutter/issues/39496
  }

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) async {
    // We do not dispatch pointer events to HTML views because they may contain
    // cross-origin iframes, which only accept user-generated events.
  }

  @override
  Future<void> dispose() async {
    assert(_instances[viewId] == this);
    _instances.remove(viewId);
    if (_instances.isEmpty) {
      html.window.removeEventListener('click', _jsGlobalClickListener);
      html.window.removeEventListener(
          'keydown', _jsGlobalKeydownListener, _useCapture);
    }
    await SystemChannels.platform_views.invokeMethod<void>('dispose', viewId);
  }
}

/// Finds the view id of the DOM element targeted by the [event].
int? getViewIdFromTarget(html.Event event) {
  final html.Element? linkElement = getLinkElementFromTarget(event);
  if (linkElement != null) {
    return linkElement.getProperty<JSNumber>(linkViewIdProperty.toJS).toDartInt;
  }
  return null;
}

/// Finds the targeted DOM element by the [event].
///
/// It handles the case where the target element is inside a shadow DOM too.
html.Element? getLinkElementFromTarget(html.Event event) {
  final html.EventTarget? target = event.target;
  if (target != null && target is html.Element) {
    if (isLinkElement(target)) {
      return target;
    }
    if (target.shadowRoot != null) {
      final html.Node? child = target.shadowRoot!.lastChild;
      if (child != null && child is html.Element && isLinkElement(child)) {
        return child;
      }
    }
  }
  return null;
}

/// Checks if the given [element] is a link that was created by
/// [LinkViewController].
bool isLinkElement(html.Element? element) {
  return element != null &&
      element.tagName == 'A' &&
      element.hasProperty(linkViewIdProperty.toJS).toDart;
}
