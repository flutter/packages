# l10n scripts
This directory contains scripts for generating Dart localizations. Currently it
is only used by material_ui and cupertino_ui.

For details that are specific to the localizations of material_ui, see
[packages/material_ui/lib/src/l10n/README.md](https://github.com/flutter/packages/blob/main/packages/material_ui/lib/src/l10n/README.md).

The Widgets library generates its localizations in a similar fashion to these
scripts, located in flutter/flutter at 
[dev/tools/localization](https://github.com/flutter/flutter/tree/master/dev/tools/localization).

## Translations for one locale: .arb files

The Material and Cupertino libraries use
[Application Resource Bundle](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
files, which have a `.arb` extension, to store localized translations
of messages, format strings, and other values. This format is also
used by the Dart [intl](https://pub.dev/packages/intl) package.

The Material and Cupertino libraries only depend on a small subset of the ARB
format. Each .arb file contains a single JSON table that maps from resource IDs
to localized values.

Filenames contain the locale that the values have been translated
for. For example `material_de.arb` contains German translations, and
`material_ar.arb` contains Arabic translations. Files that contain
regional translations have names that include the locale's regional
suffix. For example `material_en_GB.arb` contains additional English
translations that are specific to Great Britain.

There is one language-specific .arb file for each supported locale. If
an additional file with a regional suffix is present, the regional
localizations are automatically merged with the language-specific ones.

The JSON table's keys, called resource IDs, are valid Dart variable names. They
correspond to methods from the `MaterialLocalizations` or
`CupertinoLocalizations` class. For example:

Material:

```dart
Widget build(BuildContext context) {
  return TextButton(
    child: Text(
      MaterialLocalizations.of(context).cancelButtonLabel,
    ),
  );
}
```

Cupertino:

```dart
Widget build(BuildContext context) {
  return CupertinoButton(
    child: Text(
      CupertinoLocalizations.of(context).cancelButtonLabel,
    ),
  );
}
```

This widget build method creates a button whose label is the local
translation of "Cancel" which is defined for the `cancelButtonLabel`
resource ID.

Each of the language-specific .arb files contains an entry for
`cancelButtonLabel`.

## The English .arb file defines all of the resource IDs

All of the `material_*.arb` and `cupertino_*.arb` files whose names do not
include a regional suffix contain translations for the same set of resource IDs
as `material_en.arb` and `cupertino_en.arb`, respectively.

For each resource ID defined for English, there is an additional resource
with an '@' prefix. These '@' resources are not used by the generated
Dart code at run time, they just exist to inform translators about how
the value will be used, and to inform the code generator about what code
to write.

```dart
"cancelButtonLabel": "Cancel",
"@cancelButtonLabel": {
  "description": "The label for cancel buttons and menu items."
},
```

## Values with Parameters, Plurals

A few of material and cupertino translations contain `$variable` tokens. The
Material and Cupertino libraries replace these tokens with values at
run-time. For example:

Material:

```dart
"aboutListTileTitle": "About $applicationName",
```

Cupertino:

```dart
"datePickerHourSemanticsLabelOne": "$hour o'clock",
```

The value for this resource ID is retrieved with a parameterized
method instead of a simple getter:

Material:

```dart
MaterialLocalizations.of(context).aboutListTileTitle(yourAppTitle)
```

Cupertino:

```dart
CupertinoLocalizations.of(context).datePickerHourSemanticsLabel(hour)
```

The names of the `$variable` tokens must match the names of the
`MaterialLocalizations` or `CupertinoLocalizations` method parameters.

Plurals are handled similarly, with a lookup method that includes a
quantity parameter. For example:

Material: `selectedRowCountTitle` returns a string like "1 item selected" or
"no items selected".

```dart
MaterialLocalizations.of(context).selectedRowCountTitle(yourRowCount)
```

Cupertino: `datePickerMinuteSemanticsLabel` returns a string like
"1 minute" or "2 minutes".

```dart
CupertinoLocalizations.of(context).datePickerMinuteSemanticsLabel(minute)
```

Plural translations can be provided for several quantities: 0, 1, 2,
"few", "many", "other". The variations are identified by a resource ID
suffix which must be one of "Zero", "One", "Two", "Few", "Many",
"Other". The "Other" variation is used when none of the other
quantities apply. All plural resources must include a resource with
the "Other" suffix. For example:

Material: the English translations ('material_en.arb') for
`selectedRowCountTitle` are:

```dart
"selectedRowCountTitleZero": "No items selected",
"selectedRowCountTitleOne": "1 item selected",
"selectedRowCountTitleOther": "$selectedRowCount items selected",
```

Cupertino: the English translations ('cupertino_en.arb') for
`datePickerMinuteSemanticsLabel` are:

```dart
"datePickerMinuteSemanticsLabelOne": "1 minute",
"datePickerMinuteSemanticsLabelOther": "$minute minutes",
```

When defining new resources that handle pluralizations, the "One" and
the "Other" forms must, at minimum, always be defined in the source
English ARB files.

## Adding a new string to localizations

If you (someone contributing to the package) want to add a new string to the
`MaterialLocalizations` or `CupertinoLocalizations` object (e.g. because
you've added a new widget and it has a tooltip), follow these steps:

1. #### For messages without parameters, add new getter
   ```
   String get showMenuTooltip;
   ```
   to the localizations class `MaterialLocalizations`,
   in [`packages/material_ui/lib/src/material_localizations.dart`](https://github.com/flutter/packages/blob/main/packages/material_ui/lib/src/material_localizations.dart),
   or `CupertinoLocalizations`,
   in [`packages/cupertino_ui/lib/src/localizations.dart`](https://github.com/flutter/packages/blob/main/packages/cupertino_ui/lib/src/localizations.dart);

   #### For messages with parameters, add new function
   ```
   String aboutListTileTitle(String applicationName);
   ```
   to the same localization class.

2. Implement a default return value in `DefaultMaterialLocalizations` or
   `DefaultCupertinoLocalizations` in the same file as in step 1.

   #### Messages without parameters:
   ```
   @override
   String get showMenuTooltip => 'Show menu';
   ```
   #### Messages with parameters:
   ```
   @override
   String aboutListTileTitle(String applicationName) => 'About $applicationName';
   ```
   For messages with parameters, do also add the function to `GlobalMaterialLocalizations`  in [`packages/material_ui/lib/src/global_material_localizations.dart`](https://github.com/flutter/packages/blob/main/packages/material_ui/lib/src/global_material_localizations.dart) or `GlobalCupertinoLocalizations` in [`packages/cupertino_ui/lib/src/global_cupertino_localizations.dart`](https://github.com/flutter/packages/blob/main/packages/cupertino_ui/lib/src/global_cupertino_localizations.dart), and add a raw getter as demonstrated below:

   ```
   /// The raw version of [aboutListTileTitle], with `$applicationName` verbatim
   /// in the string.
   @protected
   String get aboutListTileTitleRaw;

   @override
   String aboutListTileTitle(String applicationName) {
     final String text = aboutListTileTitleRaw;
     return text.replaceFirst(r'$applicationName', applicationName);
   }
   ```

3. Add a test to the package's `test/localizations_test.dart` that verifies that
   this new value is implemented.

4. Update the .arb files. To add a new string to the .arb files, you must first
   add it to the English translations
   (`packages/material_ui/lib/src/l10n/material_en.arb` or
   `packages/cupertino_ui/lib/src/l10n/cupertino_en.arb`), including a
   description.

   #### Messages without parameters:
   ```
   "showMenuTooltip": "Show menu",
   "@showMenuTooltip": {
     "description": "The tooltip for the button that shows a popup menu."
   },
   ```

   #### Messages with parameters:
   ```
   "aboutListTileTitle": "About $applicationName",
   "@aboutListTileTitle": {
     "description": "The default title for the drawer item that shows an about page for the application. The value of $applicationName is the name of the application, like GMail or Chrome.",
     "parameters": "applicationName"
   },
   ```

   Then you need to add new entries for the string to all of the other
   language locale files by running the following from the repo root:
   ```
   dart script/l10n/bin/gen_missing_localizations.dart
   ```
   Which will copy the English strings into the other locales as placeholders
   until they can be translated.

   Finally you need to re-generate
   packages/material_ui/lib/src/l10n/generated_material_localizations.dart and
   packages/cupertino_ui/lib/src/l10n/generated_cupertino_localizations.dart by
   running the following from the repo root:
   ```
   dart script/l10n/bin/gen_localizations.dart --overwrite
   ```

   If you got an error when running this command, [this issue](https://github.com/flutter/flutter/issues/104601) might be helpful.

   TL;DR: If you got the same type of errors as discussed in the issue, run this
   instead from the repo root:
   ```
   dart script/l10n/bin/gen_localizations.dart --overwrite --remove-undefined
   ```

5. If you are a Google employee, you should then also follow the instructions
   at `go/flutter-l10n`. If you're not, don't worry about it.

## Updating an existing string

If you or someone contributing to the Flutter framework wants to modify an
existing string in the MaterialLocalizations or CupertinoLocalizations objects,
follow these steps:

1. Modify the default value of the relevant getter(s) in
   `DefaultMaterialLocalizations` or `DefaultCupertinoLocalizations`.

2. Update the .arb files. Modify the out-of-date English strings in
   `packages/material_ui/lib/src/l10n/material_en.arb` or
   `packages/cupertino_ui/lib/src/l10n/cupertino_en.arb`.

   You also need to re-generate
   `packages/material_ui/lib/src/l10n/generated_material_localizations.dart` and
   `packages/cupertino_ui/lib/src/l10n/generated_cupertino_localizations.dart` by
   running the following from the repo root:
   ```
   dart script/l10n/bin/gen_localizations.dart --overwrite
   ```

   This script may result in your updated getters being created in newer
   locales and set to the old value of the strings. This is to be expected.
   Leave them as they were generated, and they will be picked up for
   translation.

3. If you are a Google employee, you should then also follow the instructions
   at `go/flutter-l10n`. If you're not, don't worry about it.

## gen_missing_localizations.dart

The gen_missing_localizations script is used to quickly add placeholder values
to all locale files when adding a new localization string. Add the new
localization string to the English .arb file and run this script, and all other
language locale .arb files (those without a regional suffix) will be updated
with the new string.

## gen_localizations.dart

All of the localizations are combined in a single file per library
(generated_material_localizations.dart and
generated_cupertino_localizations.dart) using the gen_localizations script.

You can see what that script would generate by running the following from the
repo root:

```dart
dart script/l10n/bin/gen_localizations.dart
```

Actually update the generated files with the following run from the repo root:

```dart
dart script/l10n/bin/gen_localizations.dart --overwrite
```

The gen_localizations script just combines the contents of all of the
.arb files, each into a class which extends `GlobalMaterialLocalizations` or
`GlobalCupertinoLocalizations`. The `MaterialLocalizations` and
`CupertinoLocalizations` class implementations use these to lookup localized
resource values.

The gen_localizations script must be run by hand after .arb files have been
updated.

## Special handling for the Kannada (kn) translations

Originally, the material_kn.arb and cupertino_kn.arb files contained unicode
characters that can cause current versions of Emacs on Linux to crash. There is
more information here: https://github.com/flutter/flutter/issues/36704.

Rather than risking developers' editor sessions, the strings in these arb files
(and the code generated for them) have been encoded using the appropriate
escapes for JSON and Dart. The JSON format arb files are rewritten by
script/l10n/bin/encode_kn_arb_files.dart, which gen_localizations runs when
`--overwrite` is passed. The localizations code
generator uses generateEncodedString()
from script/l10n/lib/localizations_utils.dart.

## Translations Status, Reporting Errors

The translations (the `.arb` files) in packages/material_ui/lib/src/l10n and
packages/cupertino_ui/lib/src/l10n are based on the English translations in
`material_en.arb` and `cupertino_en.arb`. Google contributes translations for
all the languages supported by these packages. (Googlers, for more details see
<go/flutter-l10n>.)

If you have feedback about the translations please
[file an issue on the Flutter github repo](https://github.com/flutter/flutter/issues/new?template=02_bug.yml).

## See Also

The [Internationalizing Flutter Apps](https://flutter.dev/to/internationalization)
tutorial describes how to use the internationalization APIs in an
ordinary Flutter app.

[Application Resource Bundle](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
covers the `.arb` file format used to store localized translations
of messages, format strings, and other values.

The Dart [intl](https://pub.dev/packages/intl)
package supports internationalization.

The [flutter_localizations
package](https://github.com/flutter/flutter/tree/master/packages/flutter_localizations),
which contains the localizations for the core framework and is where these
Material and Cupertino localizations were originally located.
