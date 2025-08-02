import 'package:meta/meta.dart';

/// Symbol used as a Zone key to track the current GoRouter during redirects.
@internal
const Symbol currentRouterKey = #goRouterRedirectContext;
