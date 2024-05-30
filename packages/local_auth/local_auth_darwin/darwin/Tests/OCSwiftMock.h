// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>

@interface OCSwiftProtocolMock<MockType> : NSObject

@property(nonatomic, readonly) MockType protocol;

- (instancetype)init:(Protocol *)mockProtocol;

@end

@interface OCSwiftClassMock<MockType> : NSObject

@property(nonatomic, readonly) MockType object;

- (instancetype)init:(Class)classObject;

@end
