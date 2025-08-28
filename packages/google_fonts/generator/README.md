If you notice fonts that are on [fonts.google.com](https://fonts.google.com) that do not appear in
this package, it means that the generator needs to be run. The generator will
check [fonts.google.com](https://fonts.google.com) for new fonts, test the validity each URL, and
regenerate most dart code (e.g. `GoogleFonts` class), and [families_supported](./families_supported).

1. Navigate to the root directory of this project ([packages/google_fonts](..)).
2. `dart generator/generator.dart`

After generation, see [generator/families_diff](generator/families_diff) for a summary of changes, which is useful when
generating CHANGELOG.md entries.
