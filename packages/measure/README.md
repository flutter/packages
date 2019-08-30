# Install

Make sure that `pub` is on your path. Then run:
```shell
pub global activate measure
```

# Run
First, make sure that `dart` is available on your path.

Then, connect an iPhone, run a Flutter app on it, and
```shell
# assuming that you're in this directory
measure ioscpugpu new -u resources/TraceUtility -t resources/CpuGpuTemplate.tracetemplate
```

Sample output:
```
gpu: 12.4%, cpu: 22.525%
```

For more information, try
```shell
measure help
measure help ioscpugpu
measure help ioscpugpu new
measure help ioscpugpu parse
```
