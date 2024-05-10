// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FFSFileSelectorPlugin.h"

@import UIKit;

#import "messages.g.h"

/// Interface for presenting a view controller, to allow injecting an alternate
/// test implementation.
@protocol FFSViewPresenter <NSObject>
/// Wrapper for -[UIViewController presentViewController:animated:completion:].
- (void)presentViewController:(UIViewController *_Nonnull)viewControllerToPresent
                     animated:(BOOL)animated
                   completion:(void (^__nullable)(void))completion;
@end

// This header is available in the Test module. Import via "@import file_selector_ios.Test;".
@interface FFSFileSelectorPlugin () <FFSFileSelectorApi, UIDocumentPickerDelegate>

/// Overrides the view controller used for presenting the document picker.
@property(nonatomic) id<FFSViewPresenter> _Nullable viewPresenterOverride;

/// Overrides the UIDocumentPickerViewController used for file picking.
@property(nonatomic) UIDocumentPickerViewController *_Nullable documentPickerViewControllerOverride;

@end
