# fuchsia_ctl

This package is used by Flutter CI systems to manage paving and testing Fuchsia
devices.

It offers some functionality similar to the `fx` command in the Fuchsia SDK.

It is not intended for general use.

## Building

This tool is meant to be published as an AOT compiled binary distributed via
CIPD. To build the AOT binary, run `tool/build.sh`. This must be done on a
Linux machine, and will automatically download a suitable version of Dart to
build the binary.

To create the CIPD package, make sure that the `build/` folder does not contain
any files from testing (e.g. a generated `.ssh` folder from paving or a copy of
`device-finder` or `pm`). Then run:

```bash
cipd create -in build                   \
  -name flutter/fuchsia_ctl/linux-amd64 \
  -ref stable                           \
  -tag version:n.n.n
```

with an appropriate version string, after running `tool/build.sh`.
