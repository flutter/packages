/// GlassTextField — feature showcase.
///
/// Demonstrates height constraints, dynamic line counting, icon alignment,
/// and the bottom-panel composer pattern.
///
/// To run: flutter run -t lib/demos/text_field_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const TextFieldDemoApp()));
}

class TextFieldDemoApp extends StatelessWidget {
  const TextFieldDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
      home: const TextFieldDemo(),
    );
  }
}

class TextFieldDemo extends StatefulWidget {
  const TextFieldDemo({super.key});

  @override
  State<TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  // ── Search bar ──────────────────────────────────────────────────────────
  final _searchController = TextEditingController();

  // ── Expandable input ───────────────────────────────────────────────────
  final _expandController = TextEditingController();
  final _expandFocusNode = FocusNode();
  int _expandLines = 1;
  bool _expandHasFocus = false;

  // ── Chat composer ─────────────────────────────────────────────────────
  final _composerController = TextEditingController();
  int _composerLines = 1;
  final List<String> _messages = [
    'Hey! Have you tried the new glass widgets?',
    'Yes! The liquid glass looks amazing on iOS 26 🤩',
    'Try the GlassTextField — it supports height constraints now',
    'And onLineCountChanged! Watch the border radius animate…',
  ];

  @override
  void initState() {
    super.initState();
    _expandFocusNode.addListener(() {
      setState(() => _expandHasFocus = _expandFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _expandController.dispose();
    _expandFocusNode.dispose();
    _composerController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(text);
      _composerController.clear();
      _composerLines = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expandHeight =
        _expandLines > 1 ? null : (_expandHasFocus ? 46.0 : 50.0);
    final expandRadius = _expandLines <= 1 ? 22.0 : 12.0;
    final composerRadius = _composerLines <= 1 ? 22.0 : 12.0;

    return GlassPage(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF533483),
            ],
          ),
        ),
      ),
      child: GlassScaffold(
        backgroundColor: const Color(0x00000000),
        appBar: GlassAppBar(
          title: Text('GlassTextField'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Search bar ──────────────────────────────────────────────
              _section('Search bar', 'Fixed height · text stays centred'),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: GlassTextField.search(
                  controller: _searchController,
                  placeholder: 'Search…',
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    size: 20,
                    color: CupertinoColors.white.withValues(alpha: 0.60),
                  ),
                  useOwnLayer: true,
                  quality: GlassQuality.premium,
                ),
              ),

              SizedBox(height: 8),
              Divider(
                  color: CupertinoColors.white.withValues(alpha: 0.12),
                  indent: 16,
                  endIndent: 16),

              // ── Expandable input ────────────────────────────────────────
              _section(
                'Expandable input',
                'Pill when single-line · grows to fit · animated radius',
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: GlassTextField(
                    controller: _expandController,
                    focusNode: _expandFocusNode,
                    placeholder: 'Type here until text wraps…',
                    minLines: 1,
                    maxLines: _expandHasFocus ? 5 : 1,
                    height: expandHeight,
                    iconAlignment: CrossAxisAlignment.end,
                    prefixIcon: Icon(
                      _expandHasFocus
                          ? CupertinoIcons.trash
                          : CupertinoIcons.pencil,
                      color: CupertinoColors.white.withValues(alpha: 0.60),
                    ),
                    suffixIcon: _expandHasFocus
                        ? Icon(CupertinoIcons.paperplane,
                            color:
                                CupertinoColors.white.withValues(alpha: 0.70))
                        : null,
                    onLineCountChanged: (lines) {
                      setState(() => _expandLines = lines);
                    },
                    shape: LiquidRoundedSuperellipse(
                      borderRadius: expandRadius,
                    ),
                    useOwnLayer: true,
                    quality: GlassQuality.premium,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    interactionBehavior: GlassInteractionBehavior.full,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),

              SizedBox(height: 8),
              Divider(
                  color: CupertinoColors.white.withValues(alpha: 0.12),
                  indent: 16,
                  endIndent: 16),

              // ── Chat composer with bottom panel ─────────────────────────
              _section(
                'Chat composer',
                'Bottom panel · attachment bar · animated send button',
              ),

              // Message list
              SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msgIndex = _messages.length - 1 - index;
                    final isMe = msgIndex % 2 == 0;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 3),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: GlassCard(
                          useOwnLayer: true,
                          quality: GlassQuality.premium,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 16,
                          ),
                          settings: LiquidGlassSettings(
                            glassColor: isMe
                                ? CupertinoColors.activeBlue
                                    .withValues(alpha: 0.3)
                                : CupertinoColors.white.withValues(alpha: 0.15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              _messages[msgIndex],
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Composer
              Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: GlassTextField(
                  controller: _composerController,
                  placeholder: 'Message…',
                  maxLines: 6,
                  minHeight: 44,
                  maxHeight: 160,
                  iconAlignment: CrossAxisAlignment.end,
                  onLineCountChanged: (lines) {
                    setState(() => _composerLines = lines);
                  },
                  shape: LiquidRoundedSuperellipse(
                    borderRadius: composerRadius,
                  ),
                  useOwnLayer: true,
                  quality: GlassQuality.premium,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  interactionBehavior: GlassInteractionBehavior.full,
                  onChanged: (_) => setState(() {}),
                  bottom: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.paperclip,
                            size: 20,
                            color: CupertinoColors.white.withValues(alpha: 0.6),
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.camera,
                            size: 20,
                            color: CupertinoColors.white.withValues(alpha: 0.6),
                          ),
                          onPressed: () {},
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          ),
                          child: IconButton(
                            key: ValueKey(
                              _composerController.text.isNotEmpty
                                  ? 'send'
                                  : 'idle',
                            ),
                            icon: Icon(
                              CupertinoIcons.arrow_up_circle_fill,
                              size: 28,
                              color: _composerController.text.isNotEmpty
                                  ? CupertinoColors.white
                                  : CupertinoColors.white
                                      .withValues(alpha: 0.38),
                            ),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _section(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.70),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
