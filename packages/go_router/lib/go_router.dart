// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A declarative router for Flutter based on Navigation 2 supporting
/// deep linking, data-driven routes and more.
library go_router;

export 'src/builder.dart';
export 'src/configuration.dart';
export 'src/delegate.dart';
export 'src/information_provider.dart';
export 'src/match.dart' hide RouteMatchListCodec;
export 'src/misc/custom_parameter.dart';
export 'src/misc/errors.dart';
export 'src/misc/extensions.dart';
export 'src/misc/inherited_router.dart';
export 'src/pages/custom_transition_page.dart';
export 'src/parser.dart';
export 'src/route.dart';
export 'src/route_data.dart' hide NoOpPage;
export 'src/router.dart';
export 'src/state.dart' hide GoRouterStateRegistry, GoRouterStateRegistryScope;
