A [DevTools extension](https://pub.dev/packages/devtools_extensions) for Flutter's [shared_preferences](https://pub.dev/packages/shared_preferences) package.

## Features

This package contains the source code for the `package:shared_preferences` DevTools extension. With this tool, you can:

- List all keys stored in your app's `SharedPreferences`.
- Search for specific keys.
- Edit or remove values directly, with changes reflected in your app instantly.

It supports all data types available in `SharedPreferences`:

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

## Publishing this DevTools extension

The Flutter web app in this package is built and distributed as part of.
`package:shared_preferences`. If there are changes to this tool that are
ready to publish as part of `shared_preferences`, then the publish
workflow for `shared_preferences` should follow these steps prior to publishing.

1. Build the DevTools extension and move the assets to `shared_preferences`.

    ```sh
    cd shared_preferences_tool;
    flutter pub get;
    dart run devtools_extensions build_and_copy --source=. --dest=../shared_preferences/extension/devtools
    ```

2. Validate that `shared_preferences` is properly configured to distribute this extension.

    ```sh
    cd shared_preferences_tool;
    dart run devtools_extensions validate --package=../shared_preferences
    ```

3. Publish `shared_preferences` as normal.
