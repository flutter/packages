/// Apple Mail iOS 26 — High-Fidelity Showcase Demo
///
/// Replicates Apple Mail on iOS 26 matching the exact screenshot designs,
/// adopting the glass settings and color palette from [apple_messages_demo.dart],
/// and unifying the 1.2.0 "Living Chrome" features:
///   • Pinned navigation with [GlassAppBar.pinned] & Gel Morph across screens
///   • Living liquid morph-to-full compose sheet via [GlassMorphTrigger] & [GlassModalSheet]
///   • Prominent action [tintColor] capsule with auto-inverted send glyph
///   • Bottom floating utility bar with [AdaptiveLiquidGlassLayer] & [LiquidGlassBlendGroup]
///   • Options popover [GlassMenu] with Categories vs List View switcher
///   • Modular architecture with dedicated views for Mailboxes, Inbox, Detail, and Compose
///   • Strict adherence to Rule 1 & Rule 2: never glass in scrollable lists (uses clean dark card containers)
///
/// Run standalone:
///   flutter run -t lib/apple_mail/apple_mail_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'models/mail_models.dart';
import 'theme/mail_theme.dart';
import 'views/mailboxes_view.dart';

// Re-export models, theme, and views for consumers and tests
export 'models/mail_models.dart';
export 'theme/mail_theme.dart';
export 'views/compose_email_sheet.dart';
export 'views/email_detail_view.dart';
export 'views/inbox_view.dart';
export 'views/mailboxes_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();

  runApp(LiquidGlassWidgets.wrap(
    adaptiveQuality: true,
    theme: GlassThemeData.simple(
      blur: 1.8,
      thickness: 20,
      quality: GlassQuality.premium,
    ),
    child: const AppleMailDemoApp(),
  ));
}

class AppleMailDemoApp extends StatelessWidget {
  const AppleMailDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MailGlassScope(
      child: CupertinoApp(
        title: 'Apple Mail',
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        builder: (context, child) => GlassNavigationShell(child: child!),
        home: const AppleMailHomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN (Hosts Navigation Stack)
// ─────────────────────────────────────────────────────────────────────────────

class AppleMailHomeScreen extends StatefulWidget {
  const AppleMailHomeScreen({super.key});

  @override
  State<AppleMailHomeScreen> createState() => _AppleMailHomeScreenState();
}

class _AppleMailHomeScreenState extends State<AppleMailHomeScreen> {
  late List<MailItem> _emails;

  @override
  void initState() {
    super.initState();
    _emails = List.from(kInitialEmails);
  }

  void _markAllAsRead() {
    setState(() {
      for (final email in _emails) {
        email.isUnread = false;
      }
    });
  }

  void _deleteEmail(String id) {
    setState(() {
      _emails.removeWhere((e) => e.id == id);
    });
  }

  void _toggleUnread(String id) {
    setState(() {
      final email = _emails.firstWhere((e) => e.id == id);
      email.isUnread = !email.isUnread;
    });
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: No inner Navigator here. All pushes (Mailboxes → Inbox → Detail)
    // must resolve to the root CupertinoApp navigator that GlassNavigationShell
    // is wrapping. A private inner Navigator would intercept those pushes on a
    // navigator the Shell cannot see, preventing gel-morph from firing between screens.
    return MailGlassScope(
      child: MailboxesView(
        emails: _emails,
        onMarkAllAsRead: _markAllAsRead,
        onDeleteEmail: _deleteEmail,
        onToggleUnread: _toggleUnread,
      ),
    );
  }
}
