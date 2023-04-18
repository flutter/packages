import '../../billing_client_wrappers.dart';

/// Dart wrapper around [`com.android.billingclient.api.Product`](https://developer.android.com/reference/com/android/billingclient/api/QueryProductDetailsParams.Product).
class Product {
  /// Creates a new [Product].
  const Product({
    required this.id,
    required this.type,
  });

  /// The product identifier.
  final String id;

  /// The product type.
  final ProductType type;
}
