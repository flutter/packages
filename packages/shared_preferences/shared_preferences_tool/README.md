A [DevTools extension](https://pub.dev/packages/devtools_extensions) for Flutter's [shared_preferences](https://pub.dev/packages/shared_preferences) package.

## Features

This package contains the source code for the package:shared_preferences DevTools extension. With this tool, you can:

- List all keys stored in your app's SharedPreferences.
- Search for specific keys.
- Edit or remove values directly, with changes reflected in your app instantly.

It supports all data types available in SharedPreferences:

- `String`
- `int`
- `double`
- `bool`
- `List<String>`

## Running this project locally

1. Run the [example](../shared_preferences/example/) project in the `shared_preferences` package and copy its debug service URL.
2. Run the `shared_preferences_tool` project by running the following command:

```shell
flutter run -d chrome --dart-define=use_simulated_environment=true
```

For more information, see the [devtools_extensions](https://pub.dev/packages/devtools_extensions) package documentation.
