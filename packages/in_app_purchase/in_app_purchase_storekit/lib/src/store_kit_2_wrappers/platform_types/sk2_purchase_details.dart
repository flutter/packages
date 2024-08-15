import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

class SK2PurchaseDetails extends PurchaseDetails {
  SK2PurchaseDetails(
      {required super.productID,
      required super.purchaseID,
      required super.verificationData,
      required super.transactionDate,
      required super.status});

  @override
  bool get pendingCompletePurchase => status == PurchaseStatus.purchased;
}
