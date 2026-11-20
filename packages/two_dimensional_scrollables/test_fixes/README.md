## Directory contents

The Dart files and golden master `.expect` files in this directory are used to
test the [`dart fix` framework](https://dart.dev/tools/dart-fix) refactorings
used by the `two_dimensional_scrollables` package.

See `packages/two_dimensional_scrollables/lib/fix_data.yaml` for the current
`package:two_dimensional_scrollables` data-driven fixes.

To run these tests locally, run:
```sh
dart run script/tool/bin/flutter_plugin_tools.dart test-dart-fixes --packages two_dimensional_scrollables
```

For more documentation about Data Driven Fixes, see
https://dart.dev/go/data-driven-fixes#test-folder.
