## Token Defaults Generator

Script that generates component theme data defaults based on token data.

## Usage
Run this program from the root of the git repository:
```sh
dart packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart [-v]
```

This updates generated component theming files under
`packages/material_ui/lib/src/generated`.

## Templates

There is a template file for every component that needs defaults from the token
database. These templates are implemented as subclasses of either `M3TokenTemplate` or `M3ETokenTemplate`.

Templates need to override the `generateContents` method to provide the
generated code block as a string.

## Tokens

Tokens are stored in `data/`, and are sourced from an internal Google database.