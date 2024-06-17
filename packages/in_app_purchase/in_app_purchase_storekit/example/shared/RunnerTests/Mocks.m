// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "Mocks.h"
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Stubs.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

@implementation PaymentQueueStub

@synthesize transactions;
@synthesize delegate;

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
  [self.observer paymentQueue:self.realQueue removedTransactions:@[ transaction ]];
}

- (void)addPayment:(SKPayment *_Nonnull)payment {
  SKPaymentTransactionStub *transaction =
      [[SKPaymentTransactionStub alloc] initWithState:self.testState payment:payment];
  [self.observer paymentQueue:self.realQueue updatedTransactions:@[ transaction ]];
}

- (void)addTransactionObserver:(nonnull id<SKPaymentTransactionObserver>)observer {
  self.observer = observer;
}

- (void)restoreCompletedTransactions {
  [self.observer paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)self];
}

- (void)restoreCompletedTransactionsWithApplicationUsername:(nullable NSString *)username {
  [self.observer paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)self];
}

- (NSArray<SKPaymentTransaction *> *_Nonnull)getUnfinishedTransactions {
  if (self.getUnfinishedTransactionsStub) {
    return self.getUnfinishedTransactionsStub();
  } else {
    return @[];
  }
}

#if TARGET_OS_IOS
- (void)presentCodeRedemptionSheet {
  if (self.presentCodeRedemptionSheetStub) {
    self.presentCodeRedemptionSheetStub();
  }
}
#endif

#if TARGET_OS_IOS
- (void)showPriceConsentIfNeeded {
  if (self.showPriceConsentIfNeededStub) {
    self.showPriceConsentIfNeededStub();
  }
}
#endif

- (void)restoreTransactions:(nullable NSString *)applicationName {
  if (self.restoreTransactionsStub) {
    self.restoreTransactionsStub(applicationName);
  }
}

- (void)startObservingPaymentQueue {
  if (self.startObservingPaymentQueueStub) {
    self.startObservingPaymentQueueStub();
  }
}

- (void)stopObservingPaymentQueue {
  if (self.stopObservingPaymentQueueStub) {
    self.stopObservingPaymentQueueStub();
  }
}

- (void)removeTransactionObserver:(id<SKPaymentTransactionObserver>)observer {
  self.observer = nil;
}
@end

@implementation MethodChannelStub
- (void)invokeMethod:(nonnull NSString *)method arguments:(id _Nullable)arguments {
  if (self.invokeMethodChannelStub) {
    self.invokeMethodChannelStub(method, arguments);
  }
}

- (void)invokeMethod:(nonnull NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
  if (self.invokeMethodChannelWithResultsStub) {
    self.invokeMethodChannelWithResultsStub(method, arguments, callback);
  }
}

@end

@implementation TransactionCacheStub
- (void)addObjects:(nonnull NSArray *)objects forKey:(TransactionCacheKey)key {
  if (self.addObjectsStub) {
    self.addObjectsStub(objects, key);
  }
}

- (void)clear {
  if (self.clearStub) {
    self.clearStub();
  }
}

- (nonnull NSArray *)getObjectsForKey:(TransactionCacheKey)key {
  if (self.getObjectsForKeyStub) {
    return self.getObjectsForKeyStub(key);
  }
  return @[];
}
@end

@implementation PaymentQueueHandlerStub

@synthesize storefront;
@synthesize delegate;

- (void)paymentQueue:(nonnull SKPaymentQueue *)queue
    updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
  if (self.paymentQueueUpdatedTransactionsStub) {
    self.paymentQueueUpdatedTransactionsStub(queue, transactions);
  }
}

#if TARGET_OS_IOS
- (void)showPriceConsentIfNeeded {
  if (self.showPriceConsentIfNeededStub) {
    self.showPriceConsentIfNeededStub();
  }
}
#endif

- (BOOL)addPayment:(nonnull SKPayment *)payment {
  if (self.addPaymentStub) {
    return self.addPaymentStub(payment);
  } else {
    return NO;
  }
}

- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction {
  if (self.finishTransactionStub) {
    self.finishTransactionStub(transaction);
  }
}

- (nonnull NSArray<SKPaymentTransaction *> *)getUnfinishedTransactions {
  if (self.getUnfinishedTransactionsStub) {
    return self.getUnfinishedTransactionsStub();
  } else {
    return @[];
  }
}

- (nonnull instancetype)initWithQueue:(nonnull id<FLTPaymentQueueProtocol>)queue
                     transactionsUpdated:(nullable TransactionsUpdated)transactionsUpdated
                      transactionRemoved:(nullable TransactionsRemoved)transactionsRemoved
                restoreTransactionFailed:(nullable RestoreTransactionFailed)restoreTransactionFailed
    restoreCompletedTransactionsFinished:
        (nullable RestoreCompletedTransactionsFinished)restoreCompletedTransactionsFinished
                   shouldAddStorePayment:(nullable ShouldAddStorePayment)shouldAddStorePayment
                        updatedDownloads:(nullable UpdatedDownloads)updatedDownloads
                        transactionCache:(nonnull id<FLTTransactionCacheProtocol>)transactionCache {
  return [[PaymentQueueHandlerStub alloc] init];
}

#if TARGET_OS_IOS
- (void)presentCodeRedemptionSheet {
  if (self.presentCodeRedemptionSheetStub) {
    self.presentCodeRedemptionSheetStub();
  }
}
#endif

- (void)restoreTransactions:(nullable NSString *)applicationName {
  if (self.restoreTransactions) {
    self.restoreTransactions(applicationName);
  }
}

- (void)startObservingPaymentQueue {
  if (self.startObservingPaymentQueueStub) {
    self.startObservingPaymentQueueStub();
  }
}

- (void)stopObservingPaymentQueue {
  if (self.stopObservingPaymentQueueStub) {
    self.stopObservingPaymentQueueStub();
  }
}

- (nonnull instancetype)initWithQueue:(nonnull id<FLTPaymentQueueProtocol>)queue
                     transactionsUpdated:(nullable TransactionsUpdated)transactionsUpdated
                      transactionRemoved:(nullable TransactionsRemoved)transactionsRemoved
                restoreTransactionFailed:(nullable RestoreTransactionFailed)restoreTransactionFailed
    restoreCompletedTransactionsFinished:
        (nullable RestoreCompletedTransactionsFinished)restoreCompletedTransactionsFinished
                   shouldAddStorePayment:(nullable ShouldAddStorePayment)shouldAddStorePayment
                        updatedDownloads:(nullable UpdatedDownloads)updatedDownloads {
  return [[PaymentQueueHandlerStub alloc] init];
}

@end

@implementation RequestHandlerStub
- (void)startProductRequestWithCompletionHandler:(nonnull ProductRequestCompletion)completion {
  if (self.startProductRequestWithCompletionHandlerStub) {
    self.startProductRequestWithCompletionHandlerStub(completion);
  }
}
@end

/// This mock is only used in iOS tests
#if TARGET_OS_IOS

// This FlutterPluginRegistrar is a protocol, so to make a stub it has to be implemented.
@implementation FlutterPluginRegistrarStub

- (void)addApplicationDelegate:(nonnull NSObject<FlutterPlugin> *)delegate {
  if (self.addApplicationDelegateStub) {
    self.addApplicationDelegateStub(delegate);
  }
}

- (void)addMethodCallDelegate:(nonnull NSObject<FlutterPlugin> *)delegate
                       channel:(nonnull FlutterMethodChannel *)channel {
    if (self.addMethodCallDelegateStub) {
        self.addMethodCallDelegateStub(delegate, channel);
    }
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset {
    if (self.lookupKeyForAssetStub) {
        return self.lookupKeyForAssetStub(asset);
    }
    return nil;
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset
                           fromPackage:(nonnull NSString *)package {
    if (self.lookupKeyForAssetFromPackageStub) {
        return self.lookupKeyForAssetFromPackageStub(asset, package);
    }
    return nil;
}

- (nonnull NSObject<FlutterBinaryMessenger> *)messenger {
    if (self.messengerStub) {
        return self.messengerStub();
    }
    return [[FlutterBinaryMessengerStub alloc] init]; // Or default behavior
}

- (void)publish:(nonnull NSObject *)value {
    if (self.publishStub) {
        self.publishStub(value);
    }
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                    withId:(nonnull NSString *)factoryId {
    if (self.registerViewFactoryStub) {
        self.registerViewFactoryStub(factory, factoryId);
    }
}

- (nonnull NSObject<FlutterTextureRegistry> *)textures {
    if (self.texturesStub) {
        return self.texturesStub();
    }
    return nil;
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                    withId:(nonnull NSString *)factoryId
   gestureRecognizersBlockingPolicy:
       (FlutterPlatformViewGestureRecognizersBlockingPolicy)gestureRecognizersBlockingPolicy {
    if (self.registerViewFactoryWithGestureRecognizersBlockingPolicyStub) {
        self.registerViewFactoryWithGestureRecognizersBlockingPolicyStub(factory, factoryId, gestureRecognizersBlockingPolicy);
    }
}

@end


// This FlutterBinaryMessenger is a protocol, so to make a stub it has to be implemented.
@implementation FlutterBinaryMessengerStub
- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {
    if (self.cleanUpConnectionStub) {
        self.cleanUpConnectionStub(connection);
    }
}

- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData *_Nullable)message {
    if (self.sendOnChannelMessageStub) {
        self.sendOnChannelMessageStub(channel, message);
    }
}

- (void)sendOnChannel:(nonnull NSString *)channel
              message:(NSData *_Nullable)message
          binaryReply:(FlutterBinaryReply _Nullable)callback {
    if (self.sendOnChannelMessageBinaryReplyStub) {
        self.sendOnChannelMessageBinaryReplyStub(channel, message, callback);
    }
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                         binaryMessageHandler:
                                             (FlutterBinaryMessageHandler _Nullable)handler {
    if (self.setMessageHandlerOnChannelBinaryMessageHandlerStub) {
        return self.setMessageHandlerOnChannelBinaryMessageHandlerStub(channel, handler);
    }
    return 0;
}
@end

#endif
