# Flutter Packages Style Guide

## Introduction

This style guide outlines the coding conventions for contributions to the
flutter/packages repository.

## Style Guides

Code should follow the relevant style guides, and use the correct
auto-formatter, for each language, as described in
[the repository contributing guide's Style section](https://github.com/flutter/packages/blob/main/CONTRIBUTING.md#style).

## Best Practices

- Code should follow the guidance and principles described in
  [the flutter/packages contribution guide](https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md).
- Code should be tested. Changes to plugin packages, which include code written
  in C, C++, Java, Kotlin, Objective-C, or Swift, should have appropriate tests
  as described in [the plugin test guidance](https://github.com/flutter/flutter/blob/master/docs/ecosystem/testing/Plugin-Tests.md).
- PR descriptions should include the Pre-Review Checklist from
  [the PR template](https://github.com/flutter/packages/blob/main/.github/PULL_REQUEST_TEMPLATE.md),
  with all of the steps completed.

## Review Agent Guidelines

When providing a summary, the review agent must adhere to the following principles:
- **Be Objective:** Focus on a neutral, descriptive summary of the changes. Avoid subjective value judgments
  like "good," "bad," "positive," or "negative." The goal is to report what the code does, not to evaluate it.
- **Use Code as the Source of Truth:** Base all summaries on the code diff. Do not trust or rephrase the PR
  description, which may be outdated or inaccurate. A summary must reflect the actual changes in the code.
- **Be Concise:** Generate summaries that are brief and to the point. Focus on the most significant changes,
  and avoid unnecessary details or verbose explanations. This ensures the feedback is easy to scan and understand.

### Temporary dependency_overrides

It is normal practice for PRs that affect multiple packages in a federated plugin to contain a temporary
`dependency_overrides` section during initial review. The review agent should not comment about
`dependency_overrides` sections in `pubspec.yaml` files that have a comment starting with:
"FOR TESTING AND INITIAL REVIEW ONLY. DO NOT MERGE."
