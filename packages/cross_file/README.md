# cross_file

An abstraction to allow working with files across multiple platforms.

## Usage

Many packages use `XFile` as their return type. In order for your
application to consume those files, import 
`package:cross_file/cross_file.dart`, and use its methods and properties
to access the file data and metadata.

In order to instantiate a new `XFile`, import the correct factory class,
either from `package:cross_file/native/factory.dart` (for native development) or
`package:cross_file/web/factory.dart` (for web development), and use the factory
constructor more appropriate for the data that you need to handle.

The library currently supports factories for the
following source types:

|| **native** | **web** |
|-|------------|---------|
| `UInt8List`| `fromBytes` | `fromBytes` |
| `dart:io` [`File`][dart_file] | `fromFile` | ❌ |
| Filesystem path | `fromPath` | ❌ |
| Web [`File`][mdn_file] | ❌ | `fromFile` |
| Web [`Blob`][mdn_blob] | ❌ | `fromBlob` |
| `objectURL` | ❌ | `fromObjectUrl` |

[dart_file]: https://api.dart.dev/stable/3.5.2/dart-io/File-class.html
[mdn_file]: https://developer.mozilla.org/en-US/docs/Web/API/File
[mdn_blob]: https://developer.mozilla.org/en-US/docs/Web/API/Blob


### Example

<?code-excerpt "example/lib/readme_excerpts.dart (Instantiate)"?>
```dart
final XFile file = XFileFactory.fromPath('assets/hello.txt');

print('File information:');
print('- Path: ${file.path}');
print('- Name: ${file.name}');
print('- MIME type: ${file.mimeType}');

final String fileContent = await file.readAsString();
print('Content of the file: $fileContent');
```

You will find links to the API docs on the [pub page](https://pub.dev/packages/cross_file).

## Web Limitations

`XFile` on the web platform is backed by `Blob`
objects and their URLs.

It seems that Safari hangs when reading Blobs larger than 4GB (your app will stop
without returning any data, or throwing an exception).

### Browser compatibility

[![Data on Global support for Blob constructing](https://caniuse.bitsofco.de/image/blobbuilder.png)](https://caniuse.com/blobbuilder)

[![Data on Global support for Blob URLs](https://caniuse.bitsofco.de/image/bloburls.png)](https://caniuse.com/bloburls)

## Testing

This package supports both web and native platforms. Unit tests need to be split
in two separate suites (because native code cannot use `dart:html`, and web code
cannot use `dart:io`).

When adding new features, it is likely that tests need to be added for both the
native and web platforms.

### Native tests

Tests for native platforms are located in the `x_file_io_test.dart`. Tests can
be run  with `dart test`.

### Web tests

Tests for the web platform live in the `x_file_html_test.dart`. They can be run
with `dart test -p chrome`.
