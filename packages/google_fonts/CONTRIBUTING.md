# Contributing to the google_fonts package.


## Updating the fonts

If you notice fonts that are on [fonts.google.com](https://fonts.google.com) that do not appear in
this package, it means that the generator needs to be run. The generator will
check [fonts.google.com](https://fonts.google.com) for any new fonts, manually test each URL, and
regenerate the dart code.

The generator is run multiple times a month by a GitHub [workflow](.github/workflows/update_fonts.yml).

To run it manually, navigate to the root of the project, and run `dart generator/generator.dart`.
