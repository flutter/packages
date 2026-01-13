The generator will check [fonts.google.com](https://fonts.google.com) for new fonts, validate each URL, and
regenerate most Dart code (e.g. `GoogleFonts` class), and [families_supported](./families_supported).

Note: Googlers only, pending b/280786655, there is an additional prerequisite step required. Contact the Google Fonts team from the linked issue.

1. Navigate to the root directory of this project ([packages/google_fonts](..)).
2. `dart generator/generator.dart`

After generation, see the `families_diff` file for a summary of changes, which can be useful for writing `CHANGELOG.md` entries.
