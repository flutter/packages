// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/google_sign_in_ios_objc/ExceptionCatcher.h"

NSException *_Nullable GoogleSignInCatchException(void(NS_NOESCAPE ^ block)(void)) {
  @try {
    block();
  } @catch (NSException *exception) {
    return exception;
  }
  return nil;
}
