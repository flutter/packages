import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

final List<String> videoUrls = <String>[
  'https://aka-cdn.dramahub.me/films/718d7e2b71ca99b36bb3b8b97f4453d5/index.m3u8',
  'https://customer-5jdhfnsg3n4uo7jz.cloudflarestream.com/3d3bafbb8f8245189733757fb9f06b20/manifest/video.m3u8',
  'https://customer-5jdhfnsg3n4uo7jz.cloudflarestream.com/a07cbb3c111848e3806eeecc0cdcad63/manifest/video.m3u8',
  'https://ccdn.dramahub.me/videos/4d97870e3a3c4fd1a099dafb12e08504/index.m3u8',
  'https://aka-cdn.dramahub.me/films/7353f5506c082478247c679423fd21a8/index.m3u8',
];

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final int index;

  VideoPlayerWidget({super.key, required this.videoUrl, required this.index});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
            webOptions: const VideoPlayerWebOptions(),
            hlsCacheConfig: HlsCacheConfig(
                useCache: true,
                cacheKey: widget.videoUrl,
                maxCacheSize: 1024 * 1024 * 1024),
            bufferingConfig:
                const BufferingConfig(minBufferMs: 3000, maxBufferMs: 5000)));
    final int time = DateTime.now().millisecondsSinceEpoch;
    print('start ${DateTime.now()} ${widget.videoUrl}}');

    controller.initialize().then((event) async {
      print('initialize time ${DateTime.now().millisecondsSinceEpoch - time}');
      await controller.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      VideoPlayer(controller),
      Center(
        child: IconButton(
          onPressed: () {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
            setState(() {});
          },
          icon:
              Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ),
      Positioned(
        bottom: 10,
        left: 10,
        right: 10,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
        ),
      )
    ]);
  }
}

class TikTokPageView extends StatefulWidget {
  const TikTokPageView({super.key});

  @override
  State<TikTokPageView> createState() => _TikTokPageViewState();
}

class _TikTokPageViewState extends State<TikTokPageView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 600,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videoUrls.length,
            itemBuilder: (context, index) {
              return VideoPlayerWidget(
                  videoUrl: videoUrls[index], index: index);
            },
          ),
        ),
        GestureDetector(
            onTap: () {
              videoUrls.add(
                  'https://aka-cdn.dramahub.me/films/7353f5506c082478247c679423fd21a8/index.m3u8');
              setState(() {});
            },
            child: const Text(
              'Add more',
              style: TextStyle(fontSize: 25),
            )),
      ],
    );
  }
}

class TestHlsVideo extends StatelessWidget {
  const TestHlsVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  VideoPlayerController.initCache(1024 * 1024 * 1024);
                },
                child: const Text('Init cache')),
            ElevatedButton(
                onPressed: () {
                  final String link1 = videoUrls[1];
                  final String link2 = videoUrls[2];
                  VideoPlayerController.preCache(link1,
                      videoPlayerOptions: VideoPlayerOptions(
                          hlsCacheConfig:
                              HlsCacheConfig(useCache: true, cacheKey: link1)));
                  VideoPlayerController.preCache(link2,
                      videoPlayerOptions: VideoPlayerOptions(
                          hlsCacheConfig:
                              HlsCacheConfig(useCache: true, cacheKey: link2)));
                },
                child: const Text('Pre cache')),
            ElevatedButton(
                onPressed: () async {
                  print(
                      'isCached: ${await VideoPlayerController.isCached(videoUrls[1])}');
                  print(
                      'isCached: ${await VideoPlayerController.isCached(videoUrls[1])}');
                },
                child: const Text('Check cache')),
            Builder(builder: (context) {
              return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Scaffold(
                                body: TikTokPageView(),
                              )),
                    );
                  },
                  child: const Text('To video page'));
            })
          ],
        ),
      ),
    ));
  }
}
