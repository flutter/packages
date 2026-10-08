import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';

/// Quick demo: two circle buttons flanking a wide button.
/// Tests anchor stretch physics on high-aspect-ratio buttons.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const _StretchDemoApp()));
}

class _StretchDemoApp extends StatelessWidget {
  const _StretchDemoApp();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
      home: const StretchTestDemo(),
    );
  }
}

class StretchTestDemo extends StatefulWidget {
  const StretchTestDemo({super.key});

  @override
  State<StretchTestDemo> createState() => _StretchDemoPageState();
}

class _StretchDemoPageState extends State<StretchTestDemo> {
  bool switch2 = true;

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: GlassStatusBarStyle.light,
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
      ),
      child: GlassScaffold(
        appBar: const GlassAppBar.pinned(),
        body: GlassScrollEdgeEffect(
          topFadeHeight: MediaQuery.paddingOf(context).top + 44 + 40,
          fadeBottom: false,
          fadeColor: const Color(0xFF1a1a2e),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).top + 44,
                ),
              ),
              // Filler content to force scrolling
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Section 1',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white)),
                      SizedBox(height: 12),
                      Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          style: TextStyle(
                              fontSize: 15, color: Color(0xB2FFFFFF))),
                      SizedBox(height: 24),
                      Text('Section 2',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white)),
                      SizedBox(height: 12),
                      Text(
                          'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                          style: TextStyle(
                              fontSize: 15, color: Color(0xB2FFFFFF))),
                      SizedBox(height: 24),
                      Text('Section 3',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white)),
                      SizedBox(height: 12),
                      Text(
                          'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                          style: TextStyle(
                              fontSize: 15, color: Color(0xB2FFFFFF))),
                      SizedBox(height: 24),
                      Text('Section 4',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white)),
                      SizedBox(height: 12),
                      Text(
                          'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                          style: TextStyle(
                              fontSize: 15, color: Color(0xB2FFFFFF))),
                      SizedBox(height: 24),
                      Text('Section 5',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white)),
                      SizedBox(height: 12),
                      Text(
                          'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.',
                          style: TextStyle(
                              fontSize: 15, color: Color(0xB2FFFFFF))),
                      SizedBox(height: 24),
                      Text('Section 6',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white)),
                      SizedBox(height: 12),
                      Text(
                          'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores.',
                          style: TextStyle(
                              fontSize: 15, color: Color(0xB2FFFFFF))),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: AdaptiveLiquidGlassLayer(
                  child: Column(children: [
                    Row(
                      children: [
                        // Left circle button — back chevron

                        GlassButton(
                          quality: GlassQuality.premium,
                          icon: Icon(CupertinoIcons.chevron_left),
                          onTap: () {},
                          width: 56,
                          height: 56,
                          iconSize: 22,
                          //  useOwnLayer: true,
                        ),
                        SizedBox(width: 12),
                        // Wide pill button — text only
                        Expanded(
                          child: GlassButton(
                            quality: GlassQuality.premium,
                            icon: const SizedBox.shrink(),
                            label: 'Test',
                            onTap: () {},
                            height: 56,
                            iconSize: 0,
                            //  useOwnLayer: true,
                            shape:
                                const LiquidRoundedRectangle(borderRadius: 32),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Right square button — options
                        GlassButton(
                          quality: GlassQuality.premium,
                          icon: Icon(CupertinoIcons.ellipsis),
                          onTap: () {},
                          width: 56,
                          height: 56,
                          iconSize: 22,
                          //  useOwnLayer: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Test Premium toggle scroll',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                        // Premium
                        GlassSwitch(
                          value: switch2,
                          onChanged: (v) => setState(() => switch2 = v),
                          quality: GlassQuality.premium,
                        ),
                      ],
                    ),
                    SizedBox(height: 60)
                  ]),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
