// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MyApi.h"
#import <Flutter/Flutter.h>

@implementation MyApi
- (ACSearchReply*)search:(ACSearchRequest*)input error:(FlutterError**)error {
  if ([input.query isEqualToString:@"error"]) {
    *error = [FlutterError errorWithCode:@"somecode" message:@"somemessage" details:nil];
    return nil;
  } else {
    ACSearchReply* reply = [[ACSearchReply alloc] init];
    reply.result = [NSString stringWithFormat:@"Hello %@!", input.query];
    return reply;
  }
}
@end
