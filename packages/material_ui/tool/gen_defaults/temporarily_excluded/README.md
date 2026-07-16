# Temporarily Excluded `gen_defaults` Templates and Code

This directory contains the templates and generated code used by the old
`gen_defaults` script in `flutter/flutter`. They are in the process of being
migrated to the new `gen_defaults` script. Please see
https://github.com/flutter/flutter/issues/187899.

## Instructions for migrating

In these instructions, placeholders are used for the component name. Please substitute them as follows, using "Icon Button" as an example:
- `{{COMPONENT_NAME}}`: the snake_case name (e.g., `icon_button`).
- `ComponentName`: the PascalCase name (e.g., `IconButton`).
- `Component Name`: the title case name (e.g., `Icon Button`).

> Currently all `gen_defaults` migration PRs should be branched off of and rebased against the `m3e_migration` branch, not `main`. 

> Please only format the files you edit.

1. Select an unmigrated component listed in https://github.com/flutter/flutter/issues/187899.

2. Move the respective template and generated code for that template out of `temporarily_excluded/`:

   From the `packages/material_ui` directory, run:

   ```bash
   mv tool/gen_defaults/temporarily_excluded/templates/{{COMPONENT_NAME}}_template.dart tool/gen_defaults/templates/{{COMPONENT_NAME}}_template.dart
   mv tool/gen_defaults/temporarily_excluded/generated/{{COMPONENT_NAME}}_defaults.g.dart lib/src/generated/{{COMPONENT_NAME}}_defaults_m3.g.dart
   ```

3. Commit the file moves. This will allow us to review the changes on the PR.
   **Do not skip this step!**

   ```bash
   git add -A
   git commit -m "Move template/generated code out of temporarily_excluded directory"
   ```

4. Locate the respective component file that contains the generated code in `packages/material_ui/lib/src`.
   Mark it as the parent file, and delete the generated code.

   Add this line after all import statements:

   ```dart
   part 'generated/{{COMPONENT_NAME}}_defaults_m3.g.dart';
   ```

   Delete the generated code, including the headers:

   ```dart
   // BEGIN GENERATED TOKEN PROPERTIES - ComponentName

   // Do not edit by hand. The code between the "BEGIN GENERATED" and
   // "END GENERATED" comments are generated from data in the Material
   // Design token database by the script:
   //   dev/tools/gen_defaults/bin/gen_defaults.dart.

   // dart format off
   class _ComponentNameDefaultsM3 {
     ...
   }
   // dart format on

   // END GENERATED TOKEN PROPERTIES - ComponentName
   ```

5. Make the necessary changes to `tool/gen_defaults/templates/{{COMPONENT_NAME}}_template.dart`.

   These include:
   - Template class extends `TokenTemplateM3` instead of `TokenTemplate`
   - `String generate` becomes `String generateContents(String className)`
   - Use the provided `className` in `generateContents`.
   - Delete the `blockName`, `fileName`, and `tokens` super parameters.
   - Add the `name` and `parentFilePath` getters:

   ```dart
   @override
   String get name => 'Component Name';

   @override
   String get parentFilePath => 'component_name.dart';
   ```

6. Once the template compiles, uncomment it in `packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart`:

   ```dart
   const ComponentNameTemplateM3().generateFile(verbose: verbose);
   ```

7. From `packages/material_ui`, run `gen_defaults` and compare the generated code.

   ```bash
   dart run tool/gen_defaults/bin/gen_defaults.dart
   ```

8. Fill in the appropriate test case in `packages/material_ui/tool/gen_defaults/test/gen_defaults_test.dart`.