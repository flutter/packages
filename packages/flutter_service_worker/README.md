## Flutter Service Worker

A collection of utility APIs for interacting with the Flutter service worker.


### Setup

The `init` method should be called in main to bootstrap the service worker API. This is safe
to call on non-web platforms.

```dart
void main() {
  serviceWorkerApi.init();
  runApp(MyApp());
}
```


### Detecting a new version

A service worker will cache the old application until the new application is downloaded and ready. To be notified when this occurs, listen to the `newVersionReady` future. You can then use `skipWaiting()` to
force-load the new version.

```dart

serviceWorkerApi.newVersionReady.whenComplete(() {
  showNewVersionDialog().then((bool yes) {
    if (yes) {
      serviceWorkerApi.reload();
    }
  })
});

```

### Prompting for user install

Some browsers allow displaying a notification to install the web application to home screens or start menus. This can be done by waiting for `installPromptReady` to resolve. Once this is done, `showInstallPrompt()` can be called in response to user input, which will display a prompt.

```dart
serviceWorkerApi.installPromptReady.whenComplete(() {
  showVersionInstallDialog().then((bool yes) {
    if (yes) {
      serviceWorkerApi.showInstallPrompt();
    }
  });
})

```
