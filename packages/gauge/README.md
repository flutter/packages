Tools for gauging/measuring some performance metrics.

Currently there's only one tool to measure iOS CPU/GPU usages for Flutter's CI
tests.

# Install

First install [depot_tools][1] (we used its `cipd`).

Then install [dart](https://dart.dev/get-dart) and make sure that `pub` is on
your path.

Finally run:
```shell
pub global activate gauge
```

# Run
Connect an iPhone, run a Flutter app on it, and
```shell
gauge ioscpugpu new
```

Sample output:
```
gpu: 12.4%, cpu: 22.525%
```

For more information, try
```shell
gauge help
gauge help ioscpugpu
gauge help ioscpugpu new
gauge help ioscpugpu parse
```

[1]: https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up
