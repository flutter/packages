import '../messages2.g.dart';

InAppPurchase2API _hostapi = InAppPurchase2API();

class SK2Storefront {
  Future<String> countryCode() {
    return _hostapi.countryCode();
  }
}
