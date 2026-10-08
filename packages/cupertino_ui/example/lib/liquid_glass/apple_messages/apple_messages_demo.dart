/// Apple Messages iOS 26 — GlassMenu Spring Physics Test Case
///
/// This is a clone of the iOS 26 Messages app, built
/// specifically to compare [GlassMenu] spring physics against the native
/// UIKit context menu implementation side-by-side on device.
///
/// Two menus are present — mirroring the real app:
///   • Top-left  "Edit" pill  → GlassMenu anchored topLeft
///     Items: Select Messages, Edit Pins, Set Up Name & Photo
///   • Top-right filter pill  → GlassMenu anchored topRight
///     Items: Messages (✓ checked), Spam, Recently Deleted, [divider], Manage Filtering
///
/// Run standalone:
///   flutter run -t lib/apple_messages/apple_messages_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../constants/sf_symbols.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE  (matches iOS 26 dark Messages)
// ─────────────────────────────────────────────────────────────────────────────

const _kBg = CupertinoDynamicColor.withBrightness(
    // iOS system grouped background — subtle cool gray so glass pills remain
    // visible against the background even when the press specular fires bright.
    // Pure white (#FFF) gives zero contrast and makes pressed glass disappear.
    color: Color(0xFFF2F2F7),
    darkColor: Color(0xFF000000));
const _kSeparator = CupertinoColors.separator; // ~20% white
const _kAvatarBg = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE5E5EA),
    darkColor: Color(0xFF3A3A50)); // muted indigo — iOS default avatar bg
const _kBlue = CupertinoColors.systemBlue; // iOS 26 blue

// Glass shared by both menu triggers — matches the "Edit" pill aesthetic
LiquidGlassSettings _kTriggerGlass(BuildContext context) {
  final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
  return LiquidGlassSettings(
    // Dark mode: shallow bevel (thickness: 8) matched against iOS 26 nav button
    // appearance — deep enough to give subtle glass depth without concentrating
    // tint into a bright edge border. fresnelStrength + ambientStrength are zeroed
    // to match the flat UIVisualEffectView material iOS 26 uses. lightIntensity: 0.2
    // gives a soft, realistic press specular rather than an over-bright flash.
    // Light mode: full bevel (18) + Fresnel for premium 3D pressed feel.
    glassColor: isDark
        ? const Color(0xA6262626)
        : CupertinoColors.white.withValues(alpha: 0.15),
    thickness: 18.0,
    blur: isDark ? 1.8 : 8.0, // Slightly more blur dims/softens text underneath
    lightIntensity: isDark ? 0.18 : 0.45,
    ambientStrength: isDark ? 0.0 : 0.12,
    fresnelStrength: isDark ? 0.0 : 1.0,
    chromaticAberration: 0.01,
    refractiveIndex: 1.2,
    saturation: 1.0,
    shadowElevation: isDark ? 0.0 : 0.8,
  );
}

// Glass for the search+compose bar (blended group — premium needed for merging)
LiquidGlassSettings _kSearchGlass(BuildContext context) {
  final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
  return LiquidGlassSettings(
    glassColor: isDark
        ? const Color(0xA6262626)
        : CupertinoColors.white.withValues(alpha: 0.15),
    thickness: isDark ? 25.0 : 18.0,
    blur: isDark ? 1.8 : 8.0, // Slightly more blur dims/softens text underneath
    lightIntensity: isDark ? 0.18 : 0.45,
    ambientStrength: isDark ? 0.0 : 0.12,
    fresnelStrength: isDark ? 0.0 : 1.0,
    chromaticAberration: 0.01,
    refractiveIndex: 1.2,
    saturation: 1.0,
    shadowElevation: isDark ? 0.0 : 1.5,
  );
}

// Glass for the menus themselves
LiquidGlassSettings _kMenuGlass(BuildContext context) {
  final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
  return LiquidGlassSettings(
    glassColor: isDark
        ? const Color(0xFF262626).withValues(
            alpha:
                0.5) // Standard Figma approximation for systemThinMaterialDark
        : CupertinoColors.white.withValues(alpha: 0.15),
    thickness: isDark ? 25.0 : 18.0,
    blur: isDark ? 8 : 8.0, // Slightly more blur dims/softens text underneath
    lightIntensity: isDark ? 0.18 : 0.45,
    ambientStrength: isDark ? 0.0 : 0.12,
    fresnelStrength: isDark ? 0.0 : 1.0,
    chromaticAberration: 0.01,
    refractiveIndex: 1.2,
    saturation: 1.0,
    shadowElevation: isDark ? 0.0 : 1.5,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────

class _Conversation {
  const _Conversation({
    required this.name,
    required this.preview,
    required this.time,
    this.initial,
    this.isUnread = false,
    this.hasAttachment = false,
  });
  final String name;
  final String preview;
  final String time;
  final String? initial; // null → generic avatar icon
  final bool isUnread;
  final bool hasAttachment;
}

const _kConversations = [
  _Conversation(
    name: 'Mum',
    preview: 'Don\'t forget dinner on Sunday! 🍗',
    time: '5:41 pm',
    initial: 'M',
    isUnread: true,
  ),
  _Conversation(
    name: 'Work Group 💼',
    preview: 'Jake: Can everyone join the 3pm standup?',
    time: '4:56 pm',
    initial: 'W',
    isUnread: true,
  ),
  _Conversation(
    name: 'Alex',
    preview: 'You liked "Sounds good, see you there"',
    time: '11:06 am',
    initial: 'A',
  ),
  _Conversation(
    name: 'Priya',
    preview: 'Cheers! Safe travels 🙌',
    time: 'Tuesday',
    initial: 'P',
  ),
  _Conversation(
    name: 'Sam',
    preview: 'Attachment: 1 Photo',
    time: 'Tuesday',
    initial: 'S',
    hasAttachment: true,
  ),
  _Conversation(
    name: '+61 428 048 980',
    preview:
        'Hi! Just a reminder your appointment is Fri 9 May at 2:30 PM. Reply STOP to opt out.',
    time: 'Monday',
  ),
  _Conversation(
    name: '+61 482 092 063',
    preview:
        'Your parcel has been delivered to the front door. Track at auspost.com.au',
    time: 'Monday',
  ),
  _Conversation(
    name: 'Jordan',
    preview: 'haha yeah that was wild 😂',
    time: 'Monday',
    initial: 'J',
  ),
  _Conversation(
    name: 'Taylor',
    preview: 'Ok sounds good!',
    time: 'Sunday',
    initial: 'T',
  ),
  _Conversation(
    name: '+61 409 593 783',
    preview:
        'Hi! FREE flu vaccines are now available for ALL ages at participating pharmacies near you.',
    time: 'Sunday',
  ),
  _Conversation(
    name: 'Riley',
    preview: 'The reservation is at 7:30, don\'t be late lol',
    time: 'Saturday',
    initial: 'R',
    isUnread: true,
  ),
  _Conversation(
    name: 'Westpac',
    preview: 'Your statement is ready. Log in to view.',
    time: 'Saturday',
  ),
  _Conversation(
    name: 'Casey',
    preview: 'Can you send me that recipe again?',
    time: 'Fri',
    initial: 'C',
  ),
  _Conversation(
    name: 'Fitness First',
    preview: 'Your class is confirmed for tomorrow at 6:45 AM. See you there!',
    time: 'Fri',
  ),
  _Conversation(
    name: 'Dad',
    preview: 'Call me when you get a chance mate',
    time: 'Thu',
    initial: 'D',
    isUnread: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// APP ENTRY
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait — matches Messages on iPhone
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(
    child: const AppleMessagesDemoApp(),
    adaptiveQuality: true,
    // ignore: experimental_member_use
    adaptiveConfig: const GlassAdaptiveScopeConfig(
      // Left on intentionally for 0.9.1 — helps gather diagnostics
      // if the adaptive threshold fix doesn't hold on all hardware.
      debugLogDiagnostics: true,
    ),
  ));
}

class AppleMessagesDemoApp extends StatelessWidget {
  const AppleMessagesDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Messages',
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: const MessagesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _titleController = GlassLargeTitleController();

  // Tracks which filter is selected in the right menu
  String _activeFilter = 'Messages';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final botPad = MediaQuery.paddingOf(context).bottom;

    return GlassScaffold(
      background: ColoredBox(color: _kBg.resolveFrom(context)),
      settings: _kTriggerGlass(context),
      statusBarStyle: CupertinoTheme.of(context).brightness == Brightness.dark
          ? GlassStatusBarStyle.light
          : GlassStatusBarStyle.dark,
      appBarHeight: 52,
      bottomBarHeight: 60,
      appBar: _NavBar(
        topPad: topPad,
        titleController: _titleController,
        activeFilter: _activeFilter,
        onFilterChanged: (filter) => setState(() => _activeFilter = filter),
      ),
      bottomBar: _SearchBar(bottomPad: botPad),
      body: CustomScrollView(
        controller: _titleController.scrollController,
        slivers: [
          // Status bar space + nav bar height
          SliverToBoxAdapter(child: SizedBox(height: topPad + 52)),

          // Large "Messages" title (collapses on scroll automatically)
          GlassLargeTitle(
            text: 'Messages',
            controller: _titleController,
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          ),

          // Conversation rows
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ConversationRow(
                conversation: _kConversations[i],
              ),
              childCount: _kConversations.length,
            ),
          ),

          // Bottom padding — ensure last row scrolls above search bar.
          SliverToBoxAdapter(child: SizedBox(height: 92 + botPad)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV BAR
// ─────────────────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.topPad,
    required this.titleController,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final double topPad;
  final GlassLargeTitleController titleController;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return GlassAppBar(
      toolbarHeight: 52,
      // Bar title fades in automatically when large title collapses
      title: Text(
        'Messages',
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      largeTitleController: titleController,
      // The menus get their own paddings so we override the default AppBar insets
      padding: EdgeInsets.symmetric(horizontal: 12),
      leading: const _EditMenu(),
      actions: [
        _FilterMenu(
          activeFilter: activeFilter,
          onFilterChanged: onFilterChanged,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT MENU  (top-left pill → opens downLeft)
// ─────────────────────────────────────────────────────────────────────────────

class _EditMenu extends StatelessWidget {
  const _EditMenu();

  @override
  Widget build(BuildContext context) {
    return GlassMenu(
      menuWidth: 260,
      settings: _kMenuGlass(context),
      menuBorderRadius: 32,
      quality: GlassQuality.premium,
      triggerBuilder: (context, toggleMenu) {
        final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
        return GlassButton.custom(
          onTap: toggleMenu,
          width: 68,
          height: 44,
          settings: _kTriggerGlass(context),
          shape: const LiquidRoundedRectangle(borderRadius: 22),
          quality: GlassQuality.premium,
          useOwnLayer: true,
          persistPressOnDrag: true,
          ambientBaseLight: isDark ? 0.0 : 0.25,
          child: Center(
            child: Text(
              'Edit',
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
            ),
          ),
        );
      },
      items: [
        GlassMenuItem(
          title: 'Select Messages',
          icon: Icon(SFSymbols.checkmark_circle),
          onTap: () {},
        ),
        GlassMenuItem(
          title: 'Edit Pins',
          icon: Icon(SFSymbols.pin),
          onTap: () {},
        ),
        GlassMenuItem(
          title: 'Set Up Name & Photo',
          icon: Icon(SFSymbols.person_crop_circle),
          maxLines: 2,
          onTap: () {},
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER MENU  (top-right hamburger → opens downRight, has checkmark)
// ─────────────────────────────────────────────────────────────────────────────

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return GlassMenu(
      menuWidth: 240,
      settings: _kMenuGlass(context),
      menuBorderRadius: 32,
      quality: GlassQuality.premium,
      triggerBuilder: (context, toggleMenu) {
        final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
        return GlassButton(
          onTap: toggleMenu,
          width: 44,
          height: 44,
          settings: _kTriggerGlass(context),
          shape: const LiquidOval(), // 44×44 = perfect circle
          quality: GlassQuality.premium,
          useOwnLayer: true,
          persistPressOnDrag: true,
          ambientBaseLight: isDark ? 0.0 : 0.25,
          icon: Icon(
            SFSymbols.line_horizontal_3_decrease,
            color: CupertinoColors.label.resolveFrom(context),
            size: 26,
          ),
        );
      },
      items: [
        GlassMenuItem(
          title: 'Messages',
          icon: Icon(SFSymbols.bubble_left_and_bubble_right),
          trailing: activeFilter == 'Messages'
              ? Icon(SFSymbols.checkmark,
                  color: CupertinoColors.label.resolveFrom(context), size: 16)
              : null,
          onTap: () => onFilterChanged('Messages'),
        ),
        GlassMenuItem(
          title: 'Spam',
          icon: Icon(SFSymbols.xmark_bin),
          trailing: activeFilter == 'Spam'
              ? Icon(SFSymbols.checkmark,
                  color: CupertinoColors.label.resolveFrom(context), size: 16)
              : null,
          onTap: () => onFilterChanged('Spam'),
        ),
        GlassMenuItem(
          title: 'Recently Deleted',
          icon: Icon(SFSymbols.trash),
          trailing: activeFilter == 'Recently Deleted'
              ? Icon(SFSymbols.checkmark,
                  color: CupertinoColors.label.resolveFrom(context), size: 16)
              : null,
          onTap: () => onFilterChanged('Recently Deleted'),
        ),
        const GlassMenuDivider(),
        GlassMenuItem(
          title: 'Manage Filtering',
          onTap: () {},
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONVERSATION ROW
// ─────────────────────────────────────────────────────────────────────────────

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conversation});
  final _Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, right: 16, top: 10, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Unread dot column (8px wide, left of avatar) ────────────
                SizedBox(
                  width: 12,
                  child: c.isUnread
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _kBlue,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 4),

                // ── Avatar ──────────────────────────────────────────────────
                _Avatar(initial: c.initial),
                SizedBox(width: 12),

                // ── Content ─────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.name,
                              style: TextStyle(
                                color:
                                    CupertinoColors.label.resolveFrom(context),
                                fontSize: 17,
                                fontWeight: c.isUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            c.time,
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            SFSymbols.chevron_right,
                            size: 12,
                            color: CupertinoColors.tertiaryLabel
                                .resolveFrom(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        c.hasAttachment ? '📷  ${c.preview}' : c.preview,
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context),
                          fontSize: 15,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Separator indented past the dot + avatar — matches iOS 26 inset.
          // CupertinoColors.separator is too faint on pure-black; use an
          // explicit color that matches the mid-gray hairline in real Messages.
          Builder(
            builder: (context) {
              final isDark =
                  CupertinoTheme.of(context).brightness == Brightness.dark;
              return Padding(
                padding: EdgeInsets.only(left: 76),
                child: Container(
                  height: 0.33,
                  color: isDark
                      ? const Color(
                          0x60FFFFFF) // ~38% white — matches iOS 26 hairline
                      : _kSeparator.resolveFrom(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AVATAR
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({this.initial});
  final String? initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _kAvatarBg.resolveFrom(context),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: initial != null
          ? Text(
              initial!,
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            )
          : Icon(
              SFSymbols.person_fill,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              size: 28,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SEARCH + COMPOSE BAR
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.bottomPad});
  final double bottomPad;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = CupertinoTheme.of(context).brightness == Brightness.light;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Search + Compose bar ─────────────────────────────────────────────
        // AdaptiveLiquidGlassLayer provides the rendering context.
        // LiquidGlassBlendGroup inside makes the search pill and circle button
        // liquid-merge when they are close together — matching native iOS 26.
        Padding(
          // Bottom padding: when there is a large safe-area inset (iOS home indicator)
          // we subtract 8 so the bar sits at the desired visual height (26px).
          // On devices with small or no insets (Android gesture nav, iPhone SE),
          // a minimum padding of 32 ensures it's not too close to the bottom edge.
          padding: EdgeInsets.fromLTRB(
              12, 8, 12, widget.bottomPad > 32 ? widget.bottomPad - 8 : 32),
          child: AdaptiveLiquidGlassLayer(
            settings: _kSearchGlass(context),
            quality: GlassQuality.premium,
            blendAmount: 20,
            child: LiquidGlassBlendGroup(
              blend: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Search pill
                  Expanded(
                    child: GlassSearchBar(
                      focusNode: _focusNode,
                      placeholder: 'Search',
                      useOwnLayer:
                          isLight, // joins blend group in dark, separates in light to show shadow
                      settings: _kSearchGlass(context),
                      quality: GlassQuality.premium,
                      showsCancelButton: true,
                      height: 48,
                      onChanged: (_) {},
                      onCancel: () {},
                    ),
                  ),

                  // Compose circle
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedOpacity(
                      opacity: !_isFocused ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: !_isFocused
                          ? Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: GlassButton(
                                onTap: () {},
                                width: 48,
                                height: 48,
                                shape: const LiquidOval(),
                                settings: _kSearchGlass(context),
                                quality: GlassQuality.premium,
                                useOwnLayer: isLight,
                                stretch: 0.25,
                                // Light mode: higher ambient so pressed state stays visible.
                                ambientBaseLight: isLight ? 0.25 : 0.08,
                                icon: Icon(
                                  SFSymbols.square_and_pencil,
                                  color: CupertinoColors.label
                                      .resolveFrom(context),
                                  size: 26, // Increased from 22
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
