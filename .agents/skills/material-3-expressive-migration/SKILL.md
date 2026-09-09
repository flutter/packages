---
name: material-3-expressive-migration
description: Use when migrating packages/material_ui components to Material 3 Expressive, including generated defaults, component theme opt-ins, tests, examples, and release notes.
---

# Material 3 Expressive Migration

Use this skill for Material 3 Expressive component migration work in `packages/material_ui`.

Before planning or implementing a component migration, read the canonical checklist:
https://github.com/flutter/flutter/blob/master/docs/ecosystem/material_ui/Material-3-Expressive-component-migration-checklist.md

Keep these migration invariants in mind:

- Keep Material 3 as the default behavior.
- Add Material 3 Expressive behind an explicit component-level opt-in.
- Use token templates and generated defaults whenever possible.
- Keep public APIs consistent with existing Flutter style and related components.
- Add focused tests for the Expressive opt-in, generated defaults, and any new public APIs.
- Add the required pending changelog or release information for user-facing changes.
