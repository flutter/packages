# Install

Make sure that `pub` is on your path. Then run:
```shell
pub global activate measure
```

# Run
First, make sure that `dart` and `flutter` is available in your command line.

Then, connect a **single** iPhone, run a Flutter app on it, and
```shell
# assuming that you're in this directory
measure ioscpugpu new -u resources/TraceUtility -t resources/CpuGpuTemplate.tracetemplate
```

It currently outputs something like
```
gpu: 12.4%, cpu: 22.525%
```

Eventually, we'd like to hook this up to our CI system to continuously monitor
Flutter's CPU/GPU usages, which can be used to infer the energy usage.

For more information, try
```shell
measure help
measure help ioscpugpu
measure help ioscpugpu new
measure help ioscpugpu parse
```
