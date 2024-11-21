## Updating pigeon-generated files

If you update files in the pigeons/ directory, run the following
command in this directory:

```bash
flutter pub upgrade
flutter pub run pigeon --input pigeons/messages.dart
# git commit your changes so that your working environment is clean
dart run ../../../script/tool/bin/flutter_plugin_tools.dart format --current-package
```

If you update pigeon itself and want to test the changes here,
temporarily update the pubspec.yaml by adding the following to the
`dependency_overrides` section, assuming you have checked out the
`flutter/packages` repo in a sibling directory to the `plugins` repo:

```yaml
  pigeon:
    path:
      ../../../../packages/packages/pigeon/
```

Then, run the commands above. When you run `pub get` it should warn
you that you're using an override. If you do this, you will need to
publish pigeon before you can land the updates to this package, since
the CI tests run the analysis using latest published version of
pigeon, not your version or the version on `main`.

In either case, the configuration will be obtained automatically from the
`pigeons/messages.dart` file (see `ConfigurePigeon` at the top of that file).
