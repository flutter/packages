# image\_picker\_for\_web

A web implementation of [`image_picker`][1].

## Limitations on the web platform

### `XFile`

This plugin uses `XFile` objects to abstract files picked/created by the user.

Read more about `XFile` on the web in
[`package:cross_file`'s README](https://pub.dev/packages/cross_file).

### input file "accept"

In order to filter only video/image content, some browsers offer an [`accept` attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/accept) in their `input type="file"` form elements:

![Data on support for the input-file-accept feature across the major browsers from caniuse.com](https://caniuse.bitsofco.de/image/input-file-accept.png)

This feature is just a convenience for users, **not validation**.

Users can override this setting on their browsers. You must validate in your app (or server)
that the user has picked the file type that you can handle.

### input file "capture"

In order to "take a photo", some mobile browsers offer a [`capture` attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/capture):

![Data on support for the html-media-capture feature across the major browsers from caniuse.com](https://caniuse.bitsofco.de/image/html-media-capture.png)

Each browser may implement `capture` any way they please, so it may (or may not) make a
difference in your users' experience.

### input file "cancel"

The [`cancel` event](https://caniuse.com/mdn-api_htmlinputelement_cancel_event)
used by the plugin to detect when users close the file selector without picking
a file is relatively new, and will only work in recent browsers.

### `ImagePickerOptions` support

The `ImagePickerOptions` configuration object allows passing resize (`maxWidth`,
`maxHeight`) and quality (`imageQuality`) parameters to some methods of this
plugin, which in other platforms control how selected images are resized or
re-encoded.

On the web:

* `maxWidth`, `maxHeight` and `imageQuality` are not supported for `gif` images.
* `imageQuality` only affects `jpg` and `webp` images.

### `getVideo()`

The argument `maxDuration` is not supported on the web.

## Usage

### Import the package

This package is [endorsed](https://flutter.dev/to/endorsed-federated-plugin),
which means you can simply use `image_picker`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

### Use the plugin

You should be able to use `package:image_picker` _almost_ as normal.

Once the user has picked a file, the returned `XFile` instance will contain a
`network`-accessible `Blob` URL (pointing to a location within the browser).

The instance will also let you retrieve the bytes of the selected file across all platforms.

If you want to use the path directly, your code would need look like this:

<?code-excerpt "example/lib/readme_excerpts.dart (ImageFromPath)"?>
```dart
if (kIsWeb) {
  image = Image.network(pickedFile.path);
} else {
  image = Image.file(File(pickedFile.path));
}
```

Or, using bytes:

<?code-excerpt "example/lib/readme_excerpts.dart (ImageFromBytes)"?>
```dart
image = Image.memory(await pickedFile.readAsBytes());
```

[1]: https://pub.dev/packages/image_picker
