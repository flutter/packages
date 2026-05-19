---
name: dart-package-maintenance
description: |-
  Guidelines for maintaining external Dart packages, covering versioning,
  publishing workflows, and pull request management. Use when updating Dart
  packages, preparing for a release, or managing collaborative changes in a
  repository.
---

# Dart Package Maintenance

Guidelines for maintaining Dart packages in alignment with Dart team best
practices.

## Discovery

To find maintenance tasks or inconsistencies:

### Consistency Checks
Ensure the latest version in `CHANGELOG.md` matches `pubspec.yaml`:
- Compare the top header in `CHANGELOG.md` with the `version:` field in
  `pubspec.yaml`.

## Versioning

### Semantic Versioning
- **Major**: Breaking changes.
- **Minor**: New features (non-breaking API changes).
- **Patch**: Bug fixes, documentation, or non-impacting changes.
- **Unstable packages**: Use `0.major.minor+patch`.
- **Recommendation**: Aim for `1.0.0` as soon as the package is stable.

### Pre-Edit Verification
- **Check Published Versions**: Before modifying `CHANGELOG.md` or
  `pubspec.yaml`, ALWAYS check the currently released version (e.g., via
  `git tag` or `pub.dev`).
- **Do Not Amend Released Versions**: Never add new entries to a version header
  that corresponds to a released tag.
- **Increment for New Changes**: If the current version in `pubspec.yaml`
  matches a released tag, increment the version (e.g., usually to `-wip`) and
  create a new section in `CHANGELOG.md`.

  - **Consistency**: The `CHANGELOG.md` header must match the new
    `pubspec.yaml` version.

  - **SemVer Guidelines**:
    - **Breaking Changes**: Bump Major, reset Minor/Patch
      (e.g., `2.0.0-wip`, `0.5.0-wip`).
    - **New Features**: Bump Minor, reset Patch
      (e.g., `1.1.0-wip`, `0.4.5-wip`).
    - **Bug Fixes**: Bump Patch (e.g., `1.0.1-wip`).

### Changelog Content
- **Focus on User Impact**: Entries in `CHANGELOG.md` should focus on changes
  visible to or impacting the end-user (e.g., new features, bug fixes,
  breaking changes).
- **Omit Internal Changes**: Do not include internal refactorings, test
  changes, or other modifications that do not affect the package's behavior
  or API for the user.

### Work-in-Progress (WIP) Versions
- Immediately after a publish, or on the first change after a publish, update
  `pubspec.yaml` and `CHANGELOG.md` with a `-wip` suffix (e.g., `1.1.0-wip`).
- This indicates the current state is not yet published.

### Breaking Changes
- Evaluate the impact on dependent packages and internal projects.
- Consider running changes through internal presubmits if possible.
- Prefer incremental rollouts (e.g., new behavior as opt-in) to minimize
  downstream breakage.

## Publishing Process

1. **Preparation**: Remove the `-wip` suffix from `pubspec.yaml` and
   `CHANGELOG.md` in a dedicated pull request.
2. **Execution**: Run `dart pub publish` (or `flutter pub publish`) and resolve
   all warnings and errors.
3. **Tagging**: Create and push a git tag for the published version:
   - For single-package repos: `v1.2.3`
   - For monorepos: `package_name-v1.2.3`
   - Example: `git tag v1.2.3 && git push --tags`

## Pull Request Management

- **Commits**: Each PR should generally correspond to a single squashed commit
  upon merging.
- **Shared History**: Once a PR is open, avoid force pushing to the branch.
- **Conflict Resolution**: Prefer merging `main` into the PR branch rather than
  rebasing to resolve conflicts. This preserves the review history and comments.
- **Reviewing**: Add comments from the "Files changed" view to batch them.
- **Local Inspection**: Use `gh pr checkout <number>` to inspect changes
  locally in your IDE.
