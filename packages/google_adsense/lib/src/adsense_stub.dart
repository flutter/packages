import 'package:flutter/widgets.dart';

class Adsense {
  void initialize(String adClient) {
    throw 'Only supported on web';
  }

  Widget adView(
      {required String adClient,
      required String adSlot,
      String adLayoutKey = '',
      String adLayout = '',
      String adFormat = 'auto',
      bool isAdTest = false,
      bool isFullWidthResponsive = true,
      Map<String, String> slotParams = const {}}) {
    throw 'Only supported on web';
  }
}
