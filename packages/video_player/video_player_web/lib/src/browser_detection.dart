import 'package:web/web.dart' as web;

/// Browser detection copied from engine/browser_detection.dart

/// The HTML engine used by the current browser.
enum BrowserEngine {
  /// The engine that powers Chrome, Samsung Internet Browser, UC Browser,
  /// Microsoft Edge, Opera, and others.
  ///
  /// Blink is assumed in case when a more precise browser engine wasn't
  /// detected.
  blink,

  /// The engine that powers Safari.
  webkit,

  /// The engine that powers Firefox.
  firefox,
}

/// html webgl version qualifier constants.
abstract class WebGLVersion {
  /// WebGL 1.0 is based on OpenGL ES 2.0 / GLSL 1.00
  static const int webgl1 = 1;

  /// WebGL 2.0 is based on OpenGL ES 3.0 / GLSL 3.00
  static const int webgl2 = 2;
}

/// Lazily initialized current browser engine.
final BrowserEngine _browserEngine = _detectBrowserEngine();

/// Override the value of [browserEngine].
///
/// Setting this to `null` lets [browserEngine] detect the browser that the
/// app is running on.
///
/// This is intended to be used for testing and debugging only.
BrowserEngine? debugBrowserEngineOverride;

/// Returns the [BrowserEngine] used by the current browser.
///
/// This is used to implement browser-specific behavior.
BrowserEngine get browserEngine {
  return debugBrowserEngineOverride ?? _browserEngine;
}

BrowserEngine _detectBrowserEngine() {
  final String vendor = web.window.navigator.vendor;
  final String agent = web.window.navigator.userAgent.toLowerCase();
  return detectBrowserEngineByVendorAgent(vendor, agent);
}

/// Detects browser engine for a given vendor and agent string.
///
/// Used for testing this library.
BrowserEngine detectBrowserEngineByVendorAgent(String vendor, String agent) {
  if (vendor == 'Google Inc.') {
    return BrowserEngine.blink;
  } else if (vendor == 'Apple Computer, Inc.') {
    return BrowserEngine.webkit;
  } else if (agent.contains('Edg/')) {
    // Chromium based Microsoft Edge has `Edg` in the user-agent.
    // https://docs.microsoft.com/en-us/microsoft-edge/web-platform/user-agent-string
    return BrowserEngine.blink;
  } else if (vendor == '' && agent.contains('firefox')) {
    // An empty string means firefox:
    // https://developer.mozilla.org/en-US/docs/Web/API/Navigator/vendor
    return BrowserEngine.firefox;
  }

  // Assume Blink otherwise, but issue a warning.
  // ignore: avoid_print
  print(
      'WARNING: failed to detect current browser engine. Assuming this is a Chromium-compatible browser.');
  return BrowserEngine.blink;
}

/// Whether the current browser is Safari.
bool get isSafari => browserEngine == BrowserEngine.webkit;

/// Whether the current browser is Firefox.
bool get isFirefox => browserEngine == BrowserEngine.firefox;
