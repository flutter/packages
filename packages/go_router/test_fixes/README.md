## Directory contents

The Dart files and golden master `.expect` files in this directory are used to
test the [`dart fix` framework](https://dart.dev/tools/dart-fix) refactorings
used by the go_router package

See the packages/packages/go_router/lib/fix_data.yaml directory for the current
package:go_router data-driven fixes.

To run these tests locally, execute this command in the
packages/packages/go_router/test_fixes directory.
```sh
dart fix --compare-to-golden
```

For more documentation about Data Driven Fixes, see
https://dart.dev/go/data-driven-fixes#test-folder.
