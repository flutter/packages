// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MyApi.h"
#import <Flutter/Flutter.h>

@implementation MyApi
- (void)initializeWithError:(FlutterError *_Nullable *_Nonnull)error {
}

- (ACMessageSearchReply *)searchRequest:(ACMessageSearchRequest *)input
                                  error:(FlutterError **)error {
  if ([input.query isEqualToString:@"error"]) {
    *error = [FlutterError errorWithCode:@"somecode" message:@"somemessage" details:nil];
    return nil;
  } else {
    ACMessageSearchReply *reply = [[ACMessageSearchReply alloc] init];
    reply.result = [NSString stringWithFormat:@"Hello %@!", input.query];
    reply.state = ACMessageRequestStateSuccess;
    return reply;
  }
}
@end
