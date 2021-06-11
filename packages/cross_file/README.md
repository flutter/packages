# cross_file

An abstraction to allow working with files across multiple platforms.

# Usage

Import `package:cross_file/cross_file.dart`, instantiate a `CrossFile` 
using a path or byte array and use its methods and properties to 
access the file and its metadata.

Example:

```dart
import 'package:cross_file/cross_file.dart';

final file = CrossFile('assets/hello.txt');

print('File information:');
print('- Path: ${file.path}');
print('- Name: ${file.name}');
print('- MIME type: ${file.mimeType}');

final fileContent = await file.readAsString();
print('Content of the file: ${fileContent}');  // e.g. "Moto G (4)"
```

You will find links to the API docs on the [pub page](https://pub.dev/packages/cross_file).
