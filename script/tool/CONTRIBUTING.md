# Tooling Overview

This document explains the high-level structure and philosophy of this
repository tooling. It is intended for developers who want to contribute to
the tooling.

## Guiding Principles

* **Dart tooling is better than shell scripts.** Non-trivial tooling should be
  written and maintained in the language the team is most familiar with. Dart
  is also safer and more testable than shell scripts.
* **Everything should be runnable locally.** It should be trivial to run the
  same tests locally as are run in CI. This makes the development cycle much
  simpler, as contributors don't need to rely on CI cycles to get feedback, and
  also makes investigating failures faster and easier.
* **Auditability is critical.** It should be trivial to determine which tests
  ran on which packages, and what the outcome of each was. When they don't run
  for a given package, it should be clear that they didn't, and why.
* **False negatives are the worst kind of failure.** In general, it's much
  better for the default to be to fail than to silently pass. If most packages
  should run a certain kind of test, then not having that test without explicit
  opt-out should fail.
* **Tooling is better at enforcing things than humans.** If a repo standard or
  best practice can be encoded in the tooling, it should be. Reviewers should
  not need to remember to actively check for every possible violation. When
  there's judgment involved, consider defaulting to failing, and having an
  `override: *` label to allow reviewers to intentionally skip a check in
  presubmit.
* **Collecting failures is better than stopping immediately.** Unless a failure
  would prevent continuing, it is better to add the failure to a list and
  continue, then report all failures. If a package has N unrelated failures,
  it's much better to report all of them in one run, rather than requiring N
  fix/re-run cycles.

## Structure

* Most commands should be subclasses of `PackageLoopingCommand`, which handles
  all of the logic of iterating over packages and summarizing the results.
  Unless a failure is systemic, failures should be returned rather than thrown
  so that the command can continue to run for the remaining packages.
  * Overriding `packageLoopingType` allows controlling which packages are
    included (e.g., top-level only vs all sub-packages).
  * Overriding `initializeRun()` allows for setup that should happen once, such
    as reading/parsing repo-level files needed for all packages.
  * Overriding `completeRun()` allows for final one-time checks based on the
    results of all package runs.
  * Overriding `shouldIgnoreFile()` allows for skipping commands when the only
    files touched cannot possibly impact the result of the command (e.g.,
    `README.md` changes for a native unit test command). `file_filters.dart` has
    several common classes of files that can be useful for filtering.
      * Keep in mind the principle that false negatives are the worst kind of
        failure, so err on the side of *not* skipping unless you're very sure
        it's safe.
* Commands that are not package-level (e.g., the license check should run on
  every file in the repository, whether part of a package or not) should instead
  subclass the more generic `PackageCommand`.
* Very fast and simple checks should be new classes in `lib/src/validators/`
  rather than new commands, and added to `ValidateCommand`. While this is
  slightly worse for looking at failures in CI, it is much easier for
  contributors (and their agents) to run one command to do most of the checks
  rather than remembering the entire suite of commands to run.

## Types of Commands

Commands generally fall into two categories: checks and developer utilities.
* Checks are intended to be run by CI as well as locally. They generally
  validate that some desired condition is met (unit tests pass, pubspecs are
  well structured, etc.) and have a pass/fail result.
* Developer utilities are not intended to be used in CI, but instead to make
  things easier for developers. These should be documented in `README.md` for
  easier discovery.

There is some overlap between these two categories. For example, `format`
is primarily a developer utility, but with the `--fail-on-change` flag
can be used as a check in CI.
