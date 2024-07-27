import 'package:flutter/widgets.dart';

/// Main class to work with the library
class Adsense {
  /// Initialization API. Should be called ASAP, ideally in the main method of your app.
  void initialize(String adClient) {
    throw 'Only supported on web';
  }

  /// Returns a configurable AdViewWidget
  Widget adView(
      {required String adSlot,
      String adClient = '',
      bool isAdTest = false,
      Map<String, dynamic> adUnitParams = const {}}) {
    throw 'Only supported on web';
  }
}
