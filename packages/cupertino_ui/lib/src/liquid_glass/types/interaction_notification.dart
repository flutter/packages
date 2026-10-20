// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// A notification that informs parent widgets that an interaction has started.
///
/// Used by [GlassSheet] to suppress its own scaling/glow when a child
/// widget is being touched.
class InteractionNotification extends Notification {
  /// The pointer event that triggered this notification.
  final PointerDownEvent event;

  /// Creates an [InteractionNotification].
  InteractionNotification(this.event);
}
