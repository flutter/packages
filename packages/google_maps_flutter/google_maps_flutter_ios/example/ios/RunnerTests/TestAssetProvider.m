// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "TestAssetProvider.h"

@interface TestAssetProvider ()
@property(readonly, nonatomic) NSString *key;
@property(readonly, nonatomic) NSString *assetName;
@end

@implementation TestAssetProvider

- (instancetype)initWithKey:(NSString *)key forAssetName:(NSString *)assetName {
  self = [super init];
  if (self) {
    _key = key;
    _assetName = assetName;
  }
  return self;
}

- (NSString *)lookupKeyForAsset:(NSString *)asset {
  if ([asset isEqualToString:self.assetName]) {
    return self.key;
  }
  return nil;
}

- (NSString *)lookupKeyForAsset:(NSString *)asset fromPackage:(NSString *)package {
  if ([asset isEqualToString:self.assetName]) {
    return self.key;
  }
  return nil;
}

@end
