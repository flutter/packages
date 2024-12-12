import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  try {
    await driver.waitUntilFirstFrameRasterized();
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    await driver.forceGC();
    await driver.clearTimeline();
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    final Timeline timeline = await driver.traceAction(() async {
      // animate
      await Future<void>.delayed(const Duration(seconds: 10));
    });
    final TimelineSummary summary = TimelineSummary.summarize(timeline);
    await summary.writeTimelineToFile('repaint', pretty: true);
  } finally {
    await driver.close();
  }
}
