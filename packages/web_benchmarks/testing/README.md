# `testing` README

## How to run the `testing` directory tests

The tests contained in this directory use a client-server model, similar to what
the integration_test package does. In order to run the tests inside `testing`,
do the following:

* Install Chrome in a way that [tests can find it](https://github.com/flutter/packages/blob/a5a4479e176c5e909dd5d961c2c79b61ce1bf1bd/packages/web_benchmarks/lib/src/browser.dart#L216).

* Fetch dependencies for the `test_app` directory inside `testing`:

  ```bash
  cd testing/test_app
  flutter pub get
  ```

* Fetch dependencies for the `web_benchmarks` directory:

  ```bash
  cd ../..
  flutter pub get
  ```

* Run the tests with `dart`:

  ```bash
  dart testing/web_benchmarks_test.dart
  ```

_(If the above stops working, take a look at what the [`web_benchmarks_test` Cirrus step](https://github.com/flutter/packages/blob/a5a4479e176c5e909dd5d961c2c79b61ce1bf1bd/.cirrus.yml#L102-L113)
is currently doing, and update this document accordingly!)_
