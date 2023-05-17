This directory contains a partial snapshot of an old Flutter project; it is
intended to replace the corresponding parts of a newly Flutter-created project
to allow testing plugin builds with a legacy project.

It was originally created with Flutter 2.0.6. In general the guidelines are:
- Pieces here should be self-contained; avoid making a hybrid of old and new
  projects except at major cut points (e.g., platform directories). This is
  to avoid random breakage in the future. E.g., we could probably get away
  with not including android/app/src/main/res and instead layer in the
  versions from a new project, but then someday if the resources were
  renamed, there would be dangling references to the old resources in
  files that are included here.
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

- Added license boilerplate.
