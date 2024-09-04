class TransactionCallbacks: InAppPurchase2CallbackAPI {
  var callbackAPI: InAppPurchase2CallbackAPI

  init(binaryMessenger: FlutterBinaryMessenger) {
    callbackAPI = InAppPurchase2CallbackAPI(binaryMessenger: binaryMessenger)
    super.init(binaryMessenger: binaryMessenger)
  }

  @available(iOS 15.0, *)
  func transactionUpdated(updatedTransactions: Transaction, restoring: Bool = false) {
    let transactionMsg = updatedTransactions.convertToPigeon(
      restoring: restoring)
    callbackAPI.onTransactionsUpdated(newTransaction: transactionMsg) { result in
      switch result {
      case .success:
        print("Transaction updates successfully sent")
      case .failure(let error):
        print("Failed to send transaction updates: \(error)")
      }
    }
  }

}
