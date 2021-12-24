# windows_unit_tests

Unit-tests for Pigeon generated Windows C++ code.

This is intended to be run with [run_tests.sh](../../run_tests.sh)
(not yet implemented). They can be run manually via:
```sh
cd example
flutter build windows --debug
build\windows\plugins\windows_unit_tests\Debug\windows_unit_tests_test.exe
```

Tests should be added to [`pigeon_test.cpp`](windows/test/pigeon_test.cpp).
