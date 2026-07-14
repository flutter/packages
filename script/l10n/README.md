# l10n scripts
This directory contains scripts for generating Dart localizations. Currently it
is only used by material_ui and cupertino_ui.

Originally, this code was located in flutter/flutter at
[dev/tools/localization](https://github.com/flutter/flutter/tree/master/dev/tools/localization)
before Material and Cupertino were decoupled. That directory remains the place
for generating Widgets localizations.

For full instructions on how to use these scripts to generate localizations for
material_ui and cupertino_ui, see
[packages/material_ui/lib/src/l10n/README.md](https://github.com/flutter/packages/blob/main/packages/material_ui/lib/src/l10n/README.md)
and
[packages/cupertino_ui/lib/src/l10n/README.md](https://github.com/flutter/packages/blob/main/packages/cupertino_ui/lib/src/l10n/README.md),
respectively.

## gen_missing_localizations.dart

The gen_missing_localizations script is used to quickly add placeholder values
to all locale files when adding a new localization string. Add the new
localization string to the English .arb file and run this script, and all other
locale .arb files will be updated with the new string.

## gen_localizations.dart

The gen_localizations generates the Dart localization files, such as
generated_material_localizations.dart and generated_cupertino_localizations.dart
in material_ui and cupertino_ui, respectively. The script must be run by hand
after .arb files have been updated. The script optionally takes parameters

1. The path to this directory,
2. The file name prefix (the file name less the locale
   suffix) for the .arb files in this directory.

## encode_kn_arb_files.dart

The encode_kn_arb_files script is used to rewrite malformed unicode characters
from the Kannada translations due to a problem with that locale crashing Emacs.
There is more information at https://github.com/flutter/flutter/issues/36704.
