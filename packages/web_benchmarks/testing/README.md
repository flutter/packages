# `testing` README

## How to run the `testing` directory tests

The tests contained in this directory use a client-server model, similar to what
the integration_test package does. In order to run the tests inside `testing`,
do the following:

* Install Chrome in a way that [tests can find it](https://github.com/flutter/packages/blob/a5a4479e176c5e909dd5d961c2c79b61ce1bf1bd/packages/web_benchmarks/lib/src/browser.dart#L216).

* Fetch dependencies for the `test_app` directory inside `testing`:

  ```bash
  flutter pub get testing/test_app
  ```

* Fetch dependencies for the `web_benchmarks` directory:

  ```bash
  flutter pub get
  ```

* Run the tests with `flutter test`:

  ```bash
  $ flutter test testing

  00:03 +0: Can run a web benchmark
  Launching Chrome.
  Launching Google Chrome 98.0.4758.102

  Waiting for the benchmark to report benchmark profile.
  [CHROME]: [0215/133233.327761:ERROR:socket_posix.cc(150)] bind() failed: Address already in use (98)
  [CHROME]:
  [CHROME]: DevTools listening on ws://[::1]:10000/devtools/browser/4ef82be6-9b68-4fd3-ab90-cd603d25ceb1
  Connecting to DevTools: ws://localhost:10000/devtools/page/21E7271507E9BC796B957E075515520F
  Connected to Chrome tab:  (http://localhost:9999/index.html)
  Launching benchmark "scroll"
  Extracted 299 measured frames.
  Skipped 1 non-measured frames.
  Launching benchmark "page"
  [APP] Testing round 0...
  [APP] Testing round 1...
  [APP] Testing round 2...
  [APP] Testing round 3...
  [APP] Testing round 4...
  [APP] Testing round 5...
  [APP] Testing round 6...
  [APP] Testing round 7...
  [APP] Testing round 8...
  [APP] Testing round 9...
  Extracted 490 measured frames.
  Skipped 0 non-measured frames.
  Launching benchmark "tap"
  [APP] Testing round 0...
  [APP] Testing round 1...
  [APP] Testing round 2...
  [APP] Testing round 3...
  [APP] Testing round 4...
  [APP] Testing round 5...
  [APP] Testing round 6...
  [APP] Testing round 7...
  [APP] Testing round 8...
  [APP] Testing round 9...
  Extracted 299 measured frames.
  Skipped 0 non-measured frames.
  Received profile data
  00:26 +1: All tests passed!
  ```

_(If the above stops working, take a look at what the [`web_benchmarks_test` Cirrus step](https://github.com/flutter/packages/blob/a5a4479e176c5e909dd5d961c2c79b61ce1bf1bd/.cirrus.yml#L102-L113)
is currently doing, and update this document accordingly!)_
