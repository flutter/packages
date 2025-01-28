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

/// The function used to push routes to the Flutter framework.
@visibleForTesting
Future<ByteData> Function(String) pushRouteToFrameworkFunction =
    (String routeName) => pushRouteNameToFramework(null, routeName);

/// The delegate for building the [Link] widget on the web.
///
/// It uses a platform view to render an anchor element in the DOM.
class WebLinkDelegate extends StatefulWidget {
  /// Creates a delegate for the given [link].
  const WebLinkDelegate(this.link, {super.key, this.semanticsIdentifier});

  /// Information about the link built by the app.
  final LinkInfo link;

  /// A user-provided identifier to be as the [SemanticsProperties.identifier]
  /// for the link.
  ///
  /// This identifier is optional and is only useful for testing purposes.
  final String? semanticsIdentifier;

  @override
  WebLinkDelegateState createState() => WebLinkDelegateState();
}

extension on Uri {
  String getHref() {
    if (hasScheme) {
      // External URIs are not modified.
      return toString();
    }

    if (ui_web.urlStrategy == null) {
      // If there's no UrlStrategy, we leave the URI as is.
      return toString();
    }

    // In case an internal uri is given, the uri must be properly encoded
    // using the currently used UrlStrategy.
    return ui_web.urlStrategy!.prepareExternalUrl(toString());
  }
}

int _nextSemanticsIdentifier = 0;

/// The link delegate used on the web platform.
///
/// For external URIs, it lets the browser do its thing. For app route names, it
/// pushes the route name to the framework.
class WebLinkDelegateState extends State<WebLinkDelegate> {
  late LinkViewController _controller;

  late final String _semanticsIdentifier;

  @override
  void initState() {
    super.initState();
    _semanticsIdentifier =
        widget.semanticsIdentifier ?? 'link-${_nextSemanticsIdentifier++}';
  }

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
    LinkViewController.onFollowLink(_controller.viewId);
    return Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        _buildChild(context),
        Positioned.fill(
          child: _buildPlatformView(context),
        ),
      ],
    );
  }

  Widget _buildChild(BuildContext context) {
    return Semantics(
      link: true,
      identifier: _semanticsIdentifier,
      linkUrl: widget.link.uri,
      child: widget.link.builder(
        context,
        widget.link.isDisabled ? null : _followLink,
      ),
    );
  }

  Widget _buildPlatformView(BuildContext context) {
    return ExcludeFocus(
      child: ExcludeSemantics(
        child: PlatformViewLink(
          viewType: linkViewType,
          onCreatePlatformView: (PlatformViewCreationParams params) {
            _controller =
                LinkViewController.fromParams(params, _semanticsIdentifier);
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
    );
  }
}

final JSAny _useCapture = <String, Object>{'capture': true}.jsify()!;

/// Signature for the function that triggers a link.
typedef TriggerLinkCallback = void Function(
    int viewId, html.MouseEvent? mouseEvent);

/// Keeps track of the signals required to trigger a link.
///
/// Currently, the signals required are:
///
/// 1. A FollowLink signal. This signal indicates that a hit test for the link
///    was registered on the app/framework side.
///
/// 2. A DOM event signal. This signal indicates that a click or keyboard event
///    was received on the link's corresponding DOM element.
///
/// These signals can arrive in any order depending on how the user triggers
/// the link.
///
/// Each signal may be accompanied by a view ID. The view IDs, when present,
/// must match in order for the trigger to be considered valid.
///
/// The signals are reset after a certain delay to prevent them from getting
/// stale. The delay is specified by [staleTimeout].
class LinkTriggerSignals {
  /// Creates a [LinkTriggerSignals] instance that calls [triggerLink] when all
  /// the signals are received within a [staleTimeout] duration.
  LinkTriggerSignals({
    required this.triggerLink,
    required this.staleTimeout,
  });

  /// The function to be called when all signals have been received and the link
  /// is ready to be triggered.
  final TriggerLinkCallback triggerLink;

  /// Specifies the duration after which the signals are considered stale.
  ///
  /// Signals have to arrive within [staleTimeout] duration between them to be
  /// considered valid. If they don't, the signals are reset.
  final Duration staleTimeout;

  bool get _hasAllSignals => _hasFollowLink && _hasDomEvent;

  int? get _viewId {
    assert(!isViewIdMismatched);
    return _viewIdFromFollowLink ?? _viewIdFromDomEvent;
  }

  /// Triggers the link if all signals are ready and there's no view ID
  /// mismatch.
  ///
  /// If the view IDs from the signals are mismatched, the signals are reset and
  /// the browser is prevented from navigating.
  ///
  /// If the signals are ready, the link is triggered and the signals are reset.
  void triggerLinkIfReady() {
    if (isViewIdMismatched) {
      // When view IDs from signals are mismatched, let's reset the signals and
      // prevent the browser from navigating.
      _mouseEvent?.preventDefault();
      reset();
      return;
    }

    if (_hasAllSignals) {
      triggerLink(_viewId!, _mouseEvent);
      reset();
    }
  }

  /// Handles a FollowLink signal from [viewId].
  void onFollowLink({required int viewId}) {
    _hasFollowLink = true;
    _viewIdFromFollowLink = viewId;
    _didUpdate();
  }

  /// Handles a [mouseEvent] signal from a specific [viewId].
  ///
  /// * [viewId] identifies the view where the Link widget was rendered to. It
  ///   is nullable because it cannot be determined for some DOM events.
  /// * [mouseEvent] is the DOM MouseEvent that triggered this signal. It is
  ///   nullable because some signals may come from a keyboard event.
  ///
  /// If `mouseEvent` is not null, `viewId` becomes mandatory. If `viewId` is
  /// not present in this case, a [StateError] is thrown.
  void onMouseEvent({
    required int? viewId,
    required html.MouseEvent? mouseEvent,
  }) {
    if (mouseEvent != null && viewId == null) {
      throw StateError('`viewId` must be provided for mouse events');
    }
    _hasDomEvent = true;
    _viewIdFromDomEvent = viewId;
    _mouseEvent = mouseEvent;
    _didUpdate();
  }

  bool _hasFollowLink = false;
  bool _hasDomEvent = false;

  int? _viewIdFromFollowLink;
  int? _viewIdFromDomEvent;

  html.MouseEvent? _mouseEvent;

  /// Whether the view ID from various signals have a mismatch.
  ///
  /// When a signal's view ID is missing, it's not considered a mismatch.
  bool get isViewIdMismatched {
    if (_viewIdFromFollowLink == null || _viewIdFromDomEvent == null) {
      // A missing view ID is not considered a mismatch.
      return false;
    }

    return _viewIdFromFollowLink != _viewIdFromDomEvent;
  }

  Timer? _resetTimer;

  void _didUpdate() {
    _resetTimer?.cancel();
    _resetTimer = Timer(staleTimeout, reset);
  }

  /// Reset all signals to their initial state.
  void reset() {
    _resetTimer?.cancel();
    _resetTimer = null;

    _hasFollowLink = false;
    _hasDomEvent = false;

    _viewIdFromFollowLink = null;
    _viewIdFromDomEvent = null;

    _mouseEvent = null;
  }
}

/// Controls link views.
class LinkViewController extends PlatformViewController {
  /// Creates a [LinkViewController] instance with the unique [viewId].
  LinkViewController(this.viewId, this._semanticsIdentifier) {
    if (_instancesByViewId.isEmpty) {
      // This is the first controller being created, attach the global click
      // listener.
      _attachGlobalListeners();
    }
    _instancesByViewId[viewId] = this;
    _instancesBySemanticsIdentifier[_semanticsIdentifier] = this;
  }

  /// Creates and initializes a [LinkViewController] instance with the given
  /// platform view [params].
  factory LinkViewController.fromParams(
    PlatformViewCreationParams params,
    String semanticsIdentifier,
  ) {
    final int viewId = params.id;
    final LinkViewController controller =
        LinkViewController(viewId, semanticsIdentifier);
    controller._initialize().then((_) {
      /// Because _initialize is async, it can happen that [LinkViewController.dispose]
      /// may get called before this `then` callback.
      /// Check that the `controller` that was created by this factory is not
      /// disposed before calling `onPlatformViewCreated`.
      if (_instancesByViewId[viewId] == controller) {
        params.onPlatformViewCreated(viewId);
      }
    });
    return controller;
  }

  static final Map<int, LinkViewController> _instancesByViewId =
      <int, LinkViewController>{};
  static final Map<String, LinkViewController> _instancesBySemanticsIdentifier =
      <String, LinkViewController>{};

  static html.Element _viewFactory(int viewId) {
    return _instancesByViewId[viewId]!._element;
  }

  static final LinkTriggerSignals _triggerSignals = LinkTriggerSignals(
    triggerLink: _triggerLink,
    staleTimeout: const Duration(milliseconds: 500),
  );

  static final JSFunction _jsGlobalKeydownListener = _onGlobalKeydown.toJS;
  static final JSFunction _jsGlobalClickListener = _onGlobalClick.toJS;

  static void _attachGlobalListeners() {
    // Why listen in the capture phase?
    //
    // To ensure we always receive the event even if the engine calls
    // `stopPropagation`.
    html.window
      ..addEventListener('keydown', _jsGlobalKeydownListener, _useCapture)
      ..addEventListener('click', _jsGlobalClickListener, _useCapture);

    // TODO(mdebbar): Cleanup the global listeners on hot restart.
    // https://github.com/flutter/flutter/issues/148133
  }

  static void _detachGlobalListeners() {
    html.window
      ..removeEventListener('keydown', _jsGlobalKeydownListener, _useCapture)
      ..removeEventListener('click', _jsGlobalClickListener, _useCapture);
  }

  static void _onGlobalKeydown(html.KeyboardEvent event) {
    handleGlobalKeydown(event: event);
  }

  /// Global keydown handler that's called for every keydown event on the
  /// window.
  @visibleForTesting
  static void handleGlobalKeydown({required html.KeyboardEvent event}) {
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
    //    - The button widget calls `onPressed` and therefore `followLink`.
    //    - `followLink` calls `LinkViewController.registerHitTest`.
    //    - `LinkViewController.registerHitTest` sets `_hitTestedViewId`.
    // 4. The `LinkViewController` also receives the keydown event:
    //    - We check the value of `_hitTestedViewId`.
    //    - If `_hitTestedViewId` is set, it means the app triggered the link.
    //    - We navigate to the Link's URI.

    if (_isModifierKey(event)) {
      // Modifier keys (i.e. Shift, Ctrl, Alt, Meta) cannot trigger a Link.
      return;
    }

    // The keydown event is not directly associated with the target Link, so
    // we can't find the `viewId` from the event.
    _triggerSignals.onMouseEvent(viewId: null, mouseEvent: null);
    _triggerSignals.triggerLinkIfReady();
  }

  static void _onGlobalClick(html.MouseEvent event) {
    handleGlobalClick(
      event: event,
      target: event.target as html.Element?,
    );
  }

  /// Global click handler that's called for every click event on the window.
  @visibleForTesting
  static void handleGlobalClick({
    required html.MouseEvent event,
    required html.Element? target,
  }) {
    // We only want to handle clicks that land on *our* links. That could be a
    // platform view link or a semantics link.
    final int? viewIdFromTarget =
        _getViewIdFromLink(target) ?? _getViewIdFromSemanticsLink(target);

    if (viewIdFromTarget == null) {
      // The click target was not one of our links, so we don't want to
      // interfere with it.
      //
      // We also want to reset the signals to make sure we start fresh on the
      // next click.
      _triggerSignals.reset();
      return;
    }

    _triggerSignals.onMouseEvent(
      viewId: viewIdFromTarget,
      mouseEvent: event,
    );

    _triggerSignals.triggerLinkIfReady();
  }

  /// Call this method to indicate that a hit test has been registered for the
  /// given [viewId].
  static void onFollowLink(int viewId) {
    _triggerSignals.onFollowLink(viewId: viewId);
    _triggerSignals.triggerLinkIfReady();
  }

  @override
  final int viewId;

  final String _semanticsIdentifier;

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

    _element.setAttribute('aria-hidden', 'true');
    _element.setAttribute('tabIndex', '-1');

    final Map<String, dynamic> args = <String, dynamic>{
      'id': viewId,
      'viewType': linkViewType,
    };
    await SystemChannels.platform_views.invokeMethod<void>('create', args);
  }

  /// Triggers the Link that has already received all the required signals.
  ///
  /// It also handles logic for external vs internal links, triggered by a mouse
  /// vs keyboard event.
  static void _triggerLink(int viewId, html.MouseEvent? mouseEvent) {
    final LinkViewController controller = _instancesByViewId[viewId]!;

    if (mouseEvent != null && _isModifierKey(mouseEvent)) {
      // When the click is accompanied by a modifier key (e.g. cmd+click or
      // shift+click), we want to let the browser do its thing (e.g. open a new
      // tab or a new window).
      return;
    }

    if (controller._isExternalLink) {
      if (mouseEvent == null) {
        // When external links are triggered by keyboard, they are not handled by
        // the browser. So we have to launch the url manually.
        UrlLauncherPlatform.instance
            .launchUrl(controller._uri.toString(), const LaunchOptions());
      }

      // When triggerd by a mouse event, external links will be handled by the
      // browser, so we don't have to do anything.
      return;
    }

    // Internal links are pushed through Flutter's navigation system instead of
    // letting the browser handle it.
    mouseEvent?.preventDefault();
    final String routeName = controller._uri.toString();
    pushRouteToFrameworkFunction(routeName);
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
      _element.setAttribute('href', uri.getHref());
    }
  }

  late LinkTarget _target;
  String get _htmlTargetAttribute => _getHtmlTargetAttribute(_target);

  /// Set the [LinkTarget] value for this link.
  void setTarget(LinkTarget target) {
    _target = target;
    _element.setAttribute('target', _htmlTargetAttribute);
  }

  String _getHtmlTargetAttribute(LinkTarget target) {
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

  /// Finds the view ID in the Link's semantic element.
  ///
  /// Returns null if [target] is not a semantics element for one of our Links.
  static int? _getViewIdFromSemanticsLink(html.Element? target) {
    // TODO(mdebbar): The whole <flutter-view> could be inside a shadow root. In that case,
    //       the target is always the shadow root (because we are listening on window).
    if (target == null) {
      return null;
    }
    if (!_isWithinSemanticsTree(target)) {
      return null;
    }

    final html.Element? semanticsLink = _getClosestSemanticsLink(target);
    if (semanticsLink == null) {
      return null;
    }

    final String? semanticsIdentifier =
        semanticsLink.getAttribute('flt-semantics-identifier');
    if (semanticsIdentifier == null) {
      return null;
    }

    final LinkViewController? controller =
        _instancesBySemanticsIdentifier[semanticsIdentifier];
    if (controller == null) {
      return null;
    }

    semanticsLink.setAttribute('target', controller._htmlTargetAttribute);
    return controller.viewId;
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
    assert(_instancesByViewId[viewId] == this);
    assert(_instancesBySemanticsIdentifier[_semanticsIdentifier] == this);

    _instancesByViewId.remove(viewId);
    _instancesBySemanticsIdentifier.remove(_semanticsIdentifier);

    if (_instancesByViewId.isEmpty) {
      _detachGlobalListeners();
    }
    await SystemChannels.platform_views.invokeMethod<void>('dispose', viewId);
  }

  /// Resets all link-related state.
  @visibleForTesting
  static Future<void> debugReset() async {
    _triggerSignals.reset();
    for (final LinkViewController instance in _instancesByViewId.values) {
      await instance.dispose();
    }
  }
}

/// Finds the view ID in the Link's platform view element.
///
/// Returns null if [target] is not a platform view of one of our Links.
int? _getViewIdFromLink(html.Element? target) {
  final JSString linkViewIdPropertyJS = linkViewIdProperty.toJS;
  if (target != null && target.tagName.toLowerCase() == 'a') {
    return target.getProperty<JSNumber?>(linkViewIdPropertyJS)?.toDartInt;
  }
  return null;
}

/// Whether [element] is within the semantics tree of a Flutter View.
bool _isWithinSemanticsTree(html.Element element) {
  return element.closest('flt-semantics-host') != null;
}

/// Returns the closest semantics link ancestor of the given [element].
///
/// If [element] itself is a link, it is returned.
html.Element? _getClosestSemanticsLink(html.Element element) {
  assert(_isWithinSemanticsTree(element));
  return element.closest('a[id^="flt-semantic-node-"]');
}

bool _isModifierKey(html.Event event) {
  // This method accepts both KeyboardEvent and MouseEvent but there's no common
  // interface that contains the `ctrlKey`, `altKey`, `metaKey`, and `shiftKey`
  // properties. So we have to cast the event to either `KeyboardEvent` or
  // `MouseEvent` to access these properties.
  //
  // It's safe to cast both event types to `KeyboardEvent` because it's just
  // JS-interop and has no concrete runtime type.
  event as html.KeyboardEvent;
  return event.ctrlKey || event.altKey || event.metaKey || event.shiftKey;
}
