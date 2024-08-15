class TransactionCallbacks: InAppPurchase2CallbackAPI {
  var callbackAPI: InAppPurchase2CallbackAPI

  init(binaryMessenger: FlutterBinaryMessenger) {
    callbackAPI = InAppPurchase2CallbackAPI(binaryMessenger: binaryMessenger)
    super.init(binaryMessenger: binaryMessenger)
  }

  @available(iOS 15.0, *)
  func transactionUpdated(updatedTransactions: Transaction) {
    let transactionMsg = updatedTransactions.convertToPigeon(
      status: SK2ProductPurchaseResultMessage.success)
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

//private class PigeonFlutterApi {
//  var flutterAPI: MessageFlutterApi
//
//  init(binaryMessenger: FlutterBinaryMessenger) {
//    flutterAPI = MessageFlutterApi(binaryMessenger: binaryMessenger)
//  }
//
//  func callFlutterMethod(
//    aString aStringArg: String?, completion: @escaping (Result<String, Error>) -> Void
//  ) {
//    flutterAPI.flutterMethod(aString: aStringArg) {
//      completion(.success($0))
//    }
//  }
//}
