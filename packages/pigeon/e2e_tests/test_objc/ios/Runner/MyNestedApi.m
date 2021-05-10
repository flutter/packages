// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MyNestedApi.h"

@implementation MyNestedApi
- (ACSearchReply *)search:(ACNested *)input error:(FlutterError **)error {
  ACSearchReply *reply = [[ACSearchReply alloc] init];
  reply.result = [NSString stringWithFormat:@"Hello %@!", input.request.query];
  reply.state = ACRequestStateSuccess;
  return reply;
}
@end
