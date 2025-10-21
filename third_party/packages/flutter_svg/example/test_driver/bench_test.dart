import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final SerializableFinder view = find.byType('GridView');

  final FlutterDriver driver = await FlutterDriver.connect();
  try {
    await driver.waitUntilFirstFrameRasterized();
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    await driver.forceGC();
    await driver.clearTimeline();
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    final Timeline timeline = await driver.traceAction(() async {
      await driver.scroll(
        view,
        0,
        -3400,
        const Duration(seconds: 10),
        timeout: const Duration(seconds: 15),
      );
    });
    final TimelineSummary summary = TimelineSummary.summarize(timeline);
    await summary.writeTimelineToFile('bench', pretty: true);
  } finally {
    await driver.close();
  }
}
