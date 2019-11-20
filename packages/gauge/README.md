Tools for gauging/measuring some performance metrics.

Currently there's only one tool to measure iOS CPU/GPU usages for Flutter's CI
tests. It's only tested on Xcode 10 and it's known that Xcode 11 may not be
compatible.

# Install

First install Xcode 10.3 (https://developer.apple.com/download/more/),
[dart](https://dart.dev/get-dart), and
[git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
Make sure that `pub`, `git`, and `instruments` are on your path.

Then run:
```shell
pub global activate gauge
```

# Run
Connect an iPhone, run a Flutter app on it, and
```shell
pub global run gauge ioscpugpu new
```

Sample output:
```
gpu: 12.4%, cpu: 22.525%
```

For more information, try
```shell
pub global run gauge help
pub global run gauge help ioscpugpu
pub global run gauge help ioscpugpu new
pub global run gauge help ioscpugpu parse
```
