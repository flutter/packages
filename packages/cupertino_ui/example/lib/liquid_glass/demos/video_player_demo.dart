/// Demo: Glass widgets over a Video PlatformView.
///
/// Verifies that the ClipPath → ClipRRect fix (0.12.1) eliminates the
/// rectangular blur halo that appeared when glass surfaces sat on top
/// of an iOS PlatformView.
///
/// This demo places glass buttons, cards, and a bottom bar over a
/// full-screen video — the exact scenario reported in PR #61.
///
/// Run on a **physical iOS device** (Impeller) to verify:
///   - No rectangular blur halo around glass corners
///   - Glass buttons/cards render cleanly over moving video
///   - GlassBottomBar indicator morphs without rim flash
///
/// **iOS setup:** `example/ios/` is gitignored, so after `flutter create`
/// regenerates it you must add the following to
/// `example/ios/Runner/Info.plist` (inside the top-level `<dict>`):
///
/// ```xml
/// <key>NSAppTransportSecurity</key>
/// <dict>
///   <key>NSAllowsArbitraryLoads</key>
///   <true/>
/// </dict>
/// ```
///
/// Without this, `video_player` will throw a `PlatformException` with
/// `OSStatus error -12660` when loading the network video.
///
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const VideoGlassDemoApp()));
}

class VideoGlassDemoApp extends StatelessWidget {
  const VideoGlassDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Video + Glass Demo',
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
      debugShowCheckedModeBanner: false,
      home: const VideoGlassDemoPage(),
    );
  }
}

class VideoGlassDemoPage extends StatefulWidget {
  const VideoGlassDemoPage({super.key});

  @override
  State<VideoGlassDemoPage> createState() => _VideoGlassDemoPageState();
}

class _VideoGlassDemoPageState extends State<VideoGlassDemoPage> {
  late VideoPlayerController _controller;
  int _selectedTab = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        // Flutter's official sample video — known-accessible, short, colorful.
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
    )..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
        _isPlaying = true;
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      statusBarStyle: GlassStatusBarStyle.light,
      edgeToEdge: true,
      // The video IS the background — but we don't use GlassPage's
      // background parameter because the video is a PlatformView and
      // must be in the widget tree directly (not captured as a texture).
      child: GlassScaffold(
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video layer (PlatformView on iOS) ──────────────────
            if (_controller.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              Center(
                child: CircularProgressIndicator(
                    color: CupertinoColors.white.withValues(alpha: 0.54)),
              ),

            // ── Glass overlay controls ─────────────────────────────
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),

                    // Title card
                    GlassCard(
                      useOwnLayer: true,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PlatformView Test',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Glass widgets over a video PlatformView.\n'
                            'Verify: no rectangular blur halo at corners.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: CupertinoColors.white
                                          .withValues(alpha: 0.70),
                                    ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Playback controls row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassButton(
                          useOwnLayer: true,
                          quality: GlassQuality.premium,
                          icon: Icon(CupertinoIcons.backward_fill),
                          onTap: () {
                            final pos = _controller.value.position;
                            _controller.seekTo(
                              pos - const Duration(seconds: 10),
                            );
                          },
                        ),
                        SizedBox(width: 16),
                        GlassButton.custom(
                          useOwnLayer: true,
                          quality: GlassQuality.premium,
                          onTap: _togglePlayPause,
                          width: 72,
                          height: 72,
                          child: Icon(
                            _isPlaying
                                ? CupertinoIcons.pause_fill
                                : CupertinoIcons.play_fill,
                            size: 32,
                            color: CupertinoColors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        GlassButton(
                          useOwnLayer: true,
                          quality: GlassQuality.premium,
                          icon: Icon(CupertinoIcons.forward_fill),
                          onTap: () {
                            final pos = _controller.value.position;
                            _controller.seekTo(
                              pos + const Duration(seconds: 10),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Progress indicator card
                    if (_controller.value.isInitialized)
                      GlassCard(
                        useOwnLayer: true,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: CupertinoColors.white,
                            bufferedColor:
                                CupertinoColors.white.withValues(alpha: 0.24),
                            backgroundColor:
                                CupertinoColors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),

                    SizedBox(height: 80), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomBar: GlassTabBar.bottom(
          selectedIndex: _selectedTab,
          onTabSelected: (i) => setState(() => _selectedTab = i),
          selectedIconColor: CupertinoColors.white,
          unselectedIconColor: CupertinoColors.white.withValues(alpha: 0.5),
          tabs: [
            GlassTab(
              label: 'Home',
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.home),
            ),
            GlassTab(
              label: 'Browse',
              icon: Icon(CupertinoIcons.compass),
              activeIcon: Icon(CupertinoIcons.compass_fill),
            ),
            GlassTab(
              label: 'Library',
              icon: Icon(CupertinoIcons.music_albums),
              activeIcon: Icon(CupertinoIcons.music_albums_fill),
            ),
          ],
        ),
      ),
    );
  }
}
