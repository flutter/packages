import 'package:flutter/cupertino.dart';

/// The app's Cupertino strings, or the framework's own defaults when the app
/// ships no Cupertino localizations delegate at all (a bare `WidgetsApp`).
///
/// Semantic labels for controls the package draws by itself (clear, cancel,
/// dismiss) come from here, so they follow the app's locale without the
/// package carrying any text of its own. Every such label also has an
/// optional parameter on its widget for apps that want different wording.
CupertinoLocalizations glassCupertinoLocalizationsOf(BuildContext context) =>
    Localizations.of<CupertinoLocalizations>(
      context,
      CupertinoLocalizations,
    ) ??
    const DefaultCupertinoLocalizations();
