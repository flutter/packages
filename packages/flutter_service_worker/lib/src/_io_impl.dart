import 'dart:async';

import '../flutter_service_worker.dart';

/// An unsupported implementation of the [ServiceWorkerApi] for non-web
/// platforms.
class ServiceWorkerImpl extends ServiceWorkerApi {
  @override
  Future<void> get installPromptReady => Completer<void>().future;

  @override
  Future<bool> showInstallPrompt() {
    throw UnsupportedError('showInstallPrompt is only supported on the web.');
  }
}
