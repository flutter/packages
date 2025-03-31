This directory contains a partial snapshot of an old Flutter project; it is
intended to replace the corresponding parts of a newly Flutter-created project
to allow testing plugin builds with a legacy project.

It was originally created with Flutter 2.0.6. In general the guidelines are:
- Pieces here should be largely self-contained rather than portions of
  major project components; for instance, it currently contains the entire
  `android/` directory from a legacy project, rather than a subset of it
  which would be combined with a subset of a new project's `android/`
  directory. This is to avoid random breakage in the future due to
  conflicts between those subsets. For instance, we could probably get
  away with not including android/app/src/main/res for a while, and
  instead layer in the versions from a new project, but then someday
  if the resources were renamed, there would be dangling references to
  the old resources in files that are included here.
- Updates over time should be minimal. We don't expect that an unchanged
  project will keep working forever, but this directory should simulate
  a developer who has done the bare minimum to keep their project working
  as they have updated Flutter.
- Updates should be logged below.

The reason for the hybrid model, rather than checking in a full legacy
project, is to minimize unnecessary maintenance work. E.g., there's no
need to manually keep Dart code updated for Flutter changes just to
test legacy native Android build behaviors.

## Manual changes to files

The following are the changes relative to running:

```bash
flutter create -a java all_packages
```

and then deleting everything but `android/` from it:

- Added license boilerplate.
- Replaced `jcenter` in build.gradle with `mavenCentral`, due to the
  jcenter.bintray.com shutdown.
- Update `compileSdkVersion` from 30 to 33 to maintain compatibility
  with plugins that use API 34.
- Updates `gradle-wrapper.properties` from `6.7` to `6.7.1`, to add
  support for the Kotlin gradle plugin. If a user runs into this
  error, the error message is clear on how to upgrade.
- Modifies `build.gradle` to upgrade the Android Gradle Plugin (AGP)
  from version 4.1.0 to 7.0.0. If a user runs into an error with
  the AGP version, the warning is clear on how to upgrade
  the version to one that we support.
- Modifies `gradle-wrapper.properties` to upgrade the Gradle version
  from 6.7.1 to 7.0.2. If a user runs into an error with the Gradle
  version, the warning is clear on how to upgrade the version to
  one that we support.