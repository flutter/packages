import '../../billing_client_wrappers.dart';

/// Tuple object containing a product's id and type.
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
