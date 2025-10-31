// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(FirentisTFW): Remove this file when the plugin code that uses it is migrated to Swift.
// After the migration, the code should throw Swift errors instead of Objective-C exceptions, thus
// this file will not be needed.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A utility class for catching Objective-C exceptions.
///
/// It allows to execute a block of code and catch any exceptions that are thrown during its
/// execution. This is useful for bridging between Objective-C and Swift code, as Swift does not
/// support catching Objective-C exceptions directly.
@interface ExceptionCatcher : NSObject
/// Executes a block of code and catches any exceptions that are thrown.
+ (nullable NSException *)catchException:(void (^)(void))tryBlock;
@end

NS_ASSUME_NONNULL_END
