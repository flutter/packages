// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Sentry.io has a concept of "SDK", which refers to the client library or
/// tool used to submit events to Sentry.io.
///
/// This library contains Sentry.io SDK constants used by this package.
library version;

/// The SDK version reported to Sentry.io in the submitted events.
const String sdkVersion = '2.1.1';

/// The SDK name reported to Sentry.io in the submitted events.
const String sdkName = 'dart';

/// The name of the SDK platform reported to Sentry.io in the submitted events.
const String sdkPlatform = 'dart';
