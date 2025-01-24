// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// String prefix for lists that are encoded on the platform.
const String listPrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu';

/// String prefix for lists that are encoded with json in dart.
///
/// The addition of the symbol `!` was chosen as it can't be created by the
/// base 64 encoding used with [listPrefix].
const String jsonListPrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!';

/// String prefix for doubles that are encoded as strings on the platform.
const String doublePrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu';

/// String prefix for big ints that are encoded as strings on the platform.
const String bigIntPrefix = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy';
