# material_ui Library Localizations

The `.arb` files in this directory contain localized values (primarily strings)
used by the Material library. The `generated_material_localizations.dart` file
is generated from them and contains a localizations class for each locale,
which is linked with the rest of the material_ui package.

If you're looking for information about internationalizing Flutter
apps in general, see the
[Internationalizing Flutter Apps](https://flutter.dev/to/internationalization) tutorial.

The localizations for the Material library were originally located in the
[flutter_localizations package](https://github.com/flutter/flutter/tree/master/packages/flutter_localizations).

The localizations in this directory are generated with the shared scripts in
`script/l10n`. For the format of the .arb files and for how to add, update, and
generate localizations, see the
[l10n scripts README](https://github.com/flutter/packages/blob/main/script/l10n/README.md).

### scriptCategory and timeOfDayFormat for Material library

In `material_en.arb`, the values of these resource IDs are not
translations, they're keywords that help define an app's text theme
and time picker layout respectively.

The value of `timeOfDayFormat` defines how a time picker displayed by
[showTimePicker()](https://api.flutter.dev/flutter/material/showTimePicker.html)
formats and lays out its time controls. The value of `timeOfDayFormat`
must be a string that matches one of the formats defined by
<https://api.flutter.dev/flutter/material/TimeOfDayFormat.html>.
It is converted to an enum value because the `material_en.arb` file
has this value labeled as `"x-flutter-type": "icuShortTimePattern"`.

The value of `scriptCategory` is based on the
[Language categories reference](https://material.io/design/typography/language-support.html#language-categories-reference)
section in the Material spec. The Material theme uses the
`scriptCategory` value to lookup a localized version of the default
`TextTheme`, see
[Typography.geometryThemeFor](https://api.flutter.dev/flutter/material/Typography/geometryThemeFor.html).

### Support for Pashto (ps) translations

When Flutter first set up i18n for the Material library, Pashto (ps)
translations were included for the first set of Material widgets.
However, Pashto was never set up to be continuously maintained in
Flutter by Google, so material_ps.arb was never updated beyond the
initial commit.

To prevent breaking applications that rely on these original Pashto
translations, they will be kept. However, all new strings will have
the English translation until support for Pashto is provided.
See https://github.com/flutter/flutter/issues/60598.
