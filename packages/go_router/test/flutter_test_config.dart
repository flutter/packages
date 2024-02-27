import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

FutureOr<void> testExecutable(FutureOr<void> Function() testMain) {
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings
      .copyWith(ignore: false)
      .withIgnored(allNotGCed: true);

  return testMain();
}
