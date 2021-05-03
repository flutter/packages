// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MyFlutterViewController.h"
#import "MyApi.h"
#import "MyNestedApi.h"
#import "dartle.h"

@interface MyFlutterViewController ()
@end

@implementation MyFlutterViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  ACApiSetup(self.engine.binaryMessenger, [[MyApi alloc] init]);
  ACNestedApiSetup(self.engine.binaryMessenger, [[MyNestedApi alloc] init]);
}

@end
