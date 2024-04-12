import Flutter
import XCTest
import StoreKit

@testable import in_app_purchase_storekit

protocol SKPaymentQueueProtocol {
  @available(iOS 13.0, *)
  var storefront: SKStorefront? {
    get
  }
}
extension SKPaymentQueue: SKPaymentQueueProtocol {}

class MockSKPaymentQueue: SKPaymentQueueProtocol {
  var storefront: SKStorefront?
}






protocol SKStorefrontProtocol {
}

@available(iOS 13.0, *)
extension SKStorefront:SKStorefrontProtocol {}

public protocol FIAReceiptManagerProtocol {

}
extension FIAPReceiptManager: FIAReceiptManagerProtocol {}

@available(iOS 13.0, *)


@available(iOS 13.0, *)
class MockFIAPReceiptManager:FIAPReceiptManager {

}

@available(iOS 13.0, *)
class MockStorefront: SKStorefront {
}



class MockFIATransactionCache: FIATransactionCache {

}

final class InAppPurchasePluginTests: XCTestCase {
  var plugin:InAppPurchasePlugin!;

  override func setUp() async throws {
    if #available(iOS 13.0, *) {
      var receiptManager:FIAPReceiptManager = MockFIAPReceiptManager()
    } else {
      // Fallback on earlier versions
    };
    plugin = InAppPurchasePlugin.init(receiptManager: receiptManager)
  }

  func testCanMakePayments() {
    var result:Bool = plugin.canMakePayments();
    XCTAssert(result);
  }

  func testPaymentQueueStorefront() {
    if #available(iOS 13.0, macOS 10.15, *) {
      let storefrontMap: [String: String] = [
          "countryCode": "USA",
          "identifier": "unique_identifier",
      ]
      plugin.paymentQueueHandler = FIAPaymentQueueHandler(queue: MockSKPaymentQueue(), transactionsUpdated: nil, transactionRemoved: nil, restoreTransactionFailed: nil, restoreCompletedTransactionsFinished: nil, shouldAddStorePayment: nil, updatedDownloads: nil, transactionCache: MockFIATransactionCache())
    }
  }


  //- (void)testPaymentQueueStorefront {
  //  if (@available(iOS 13, macOS 10.15, *)) {
  //    SKPaymentQueue *mockQueue = OCMClassMock(SKPaymentQueue.class);
  //    NSDictionary *storefrontMap = @{
  //      @"countryCode" : @"USA",
  //      @"identifier" : @"unique_identifier",
  //    };
  //
  //    OCMStub(mockQueue.storefront).andReturn([[SKStorefrontStub alloc] initWithMap:storefrontMap]);
  //
  //    self.plugin.paymentQueueHandler =
  //        [[FIAPaymentQueueHandler alloc] initWithQueue:mockQueue
  //                                  transactionsUpdated:nil
  //                                   transactionRemoved:nil
  //                             restoreTransactionFailed:nil
  //                 restoreCompletedTransactionsFinished:nil
  //                                shouldAddStorePayment:nil
  //                                     updatedDownloads:nil
  //                                     transactionCache:OCMClassMock(FIATransactionCache.class)];
  //
  //    FlutterError *error;
  //    SKStorefrontMessage *result = [self.plugin storefrontWithError:&error];
  //
  //    XCTAssertEqualObjects(result.countryCode, storefrontMap[@"countryCode"]);
  //    XCTAssertEqualObjects(result.identifier, storefrontMap[@"identifier"]);
  //    XCTAssertNil(error);
  //  } else {
  //    NSLog(@"Skip testPaymentQueueStorefront for iOS lower than 13.0 or macOS lower than 10.15.");
  //  }
  //}
}


