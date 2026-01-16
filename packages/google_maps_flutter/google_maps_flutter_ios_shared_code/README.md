# Shared source-of-truth code for google_maps_flutter on iOS

This directory is not a package; instead it contains code that should be
identical in all versions of `google_maps_flutter_ios_*`. While each package
has its own copy of these files—allowing us to maintain multiple major version
wrappers without complex branching—each implementation package has a CI test
that validates that its copies of these files have not diverged.

This means that for almost all changes to `google_maps_flutter_ios_*`, the
changes need to be copied here, and to all instances of the package, with any
instance of the package name itself changed in each copy.

See [this design document](https://docs.google.com/document/d/1g_GeFy4FnTHgUg-Kdmh5VOU8qOGaxGZ0J7cW75Gy8Uk/edit?usp=sharing)
for background on why the packages are structured this way. This approach
corresponds to solution E.1b in that document.

When a new major version of the Google Maps SDK is released:
- Copy the latest google_maps_flutter_ios_sdk{N} package to
  google_maps_flutter_ios_sdk{N+1}.
- Update the package name in all the relevant places (Swift Package directory
  structure, pubspec, top-level lib/ file, pigeons/messages.dart, etc.).
- Update the versions in Package.swift.
  - When creating google_maps_flutter_ios_sdk11, delete the podspec, since
    version 10 is the last to support CocoaPods.
- Update the minimum deployment version in the example/ Xcode project.
- If there are any source-level breaking changes, fork files as necessary.
  When feasible, refactor to minimize the amount of code that needs to diverge
  from the shared source files.
