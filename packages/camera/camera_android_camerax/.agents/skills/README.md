# Agent Skills

This directory contains skills intended for repository maintainers and contributors. Local, checked-in skills are evaluated by `dart_skills_lint` and should be configured to prevent publishing to pub.dev.

## Key Terms for Skills
- **user**: The human user of the skill.

## Note on Remotely Managed Skills

Skills that are remotely defined and managed using `npx skills` should **not** be installed directly into this directory. Instead, they must be installed into the repository root's `third_party/` directory to comply with third-party code policies. Once installed there, they should be symlinked into this directory. 

Please see the `third_party/README.md` file at the root of the repository for specific rules and instructions on adding new remote skills.