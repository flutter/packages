// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/in_app_purchase_storekit_objc/FIAPReceiptManager.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif
#import "./include/in_app_purchase_storekit_objc/FIAObjectTranslator.h"

@interface FIAPReceiptManager ()
// Gets the receipt file data from the location of the url. Can be nil if
// there is an error. This interface is defined so it can be stubbed for testing.
- (NSData *)getReceiptData:(NSURL *)url error:(NSError **)error;
// Gets the app store receipt url. Can be nil if
// there is an error. This property is defined so it can be stubbed for testing.
@property(nonatomic, readonly) NSURL *receiptURL;
@end

@implementation FIAPReceiptManager

- (NSString *)retrieveReceiptWithError:(FlutterError **)flutterError {
  NSURL *receiptURL = self.receiptURL;
  if (!receiptURL) {
    return nil;
  }
  NSError *receiptError;
  NSData *receipt = [self getReceiptData:receiptURL error:&receiptError];
  if (!receipt || receiptError) {
    if (flutterError) {
      NSDictionary *errorMap = [FIAObjectTranslator getMapFromNSError:receiptError];
      *flutterError =
          [FlutterError errorWithCode:[NSString stringWithFormat:@"%@", errorMap[@"code"]]
                              message:errorMap[@"domain"]
                              details:errorMap[@"userInfo"]];
    }
    return nil;
  }
  return [receipt base64EncodedStringWithOptions:kNilOptions];
}

- (NSData *)getReceiptData:(NSURL *)url error:(NSError **)error {
  return [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:error];
}

- (NSURL *)receiptURL {
  return [[NSBundle mainBundle] appStoreReceiptURL];
}

@end
