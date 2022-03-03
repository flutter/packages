// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MyNestedApi.h"

@implementation MyNestedApi
- (ACMessageSearchReply *)searchNested:(ACMessageNested *)input error:(FlutterError **)error {
  ACMessageSearchReply *reply = [[ACMessageSearchReply alloc] init];
  reply.result = [NSString stringWithFormat:@"Hello %@!", input.request.query];
  reply.state = ACMessageRequestStateSuccess;
  return reply;
}
@end
