# Shared source-of-truth code for google_maps_flutter on iOS

This directory is not a package; instead it contains code that should be
identical in all versions of `google_maps_flutter_ios_*`. While each package
has its own copy of these files—allowing us to maintain multiple major version
wrappers without complex branching or symlinking—each implementation package
has a CI test that validates that its copies of these files have not diverged.

This means that for almost all changes to `google_maps_flutter_ios_*`, the
changes need to be copied here, and to all instances of the package.

See [this design document](https://docs.google.com/document/d/1g_GeFy4FnTHgUg-Kdmh5VOU8qOGaxGZ0J7cW75Gy8Uk/edit?usp=sharing)
for background on why the packages are structured this way. This approach
corresponds to solution E.1b in that document.
