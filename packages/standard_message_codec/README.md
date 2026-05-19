<?code-excerpt path-base="example/lib"?>

An efficient and schemaless binary format used by the Flutter SDK.

## Features

### Efficiency

The standard message codec is a binary format, as opposed to text based formats
like JSON. Consider the following snippet of JSON:

```json
{
    "data": [1, 2, 3, 4],
}
```

In order for this message to be decoded into a Dart map, a utf8 binary file must
first be parsed and validated into a Dart string. Then a second pass is performed
which looks for specific characters that indicate JSON structures - for example
"{" and "}". No sizes or lengths are known ahead of time while, parsing, so the
resulting Dart list created for the "data" key is append to as decoding happens.

In contrast, decoding the standard message codec version of this message avoids
utf8 decoding, instead operating on the bytes themselves. The only string constructed
will be for the "data" key. The length of the list in the data field is encoded in
the structure, meaning the correct length object can be allocated and filled in
as decoding happens.

### Schemaless

Using standard message codec does not require a schema (like protobuf) or any
generated code. This makes it easy to use for dynamic messages and simplifies
the integration into existing codebases.

The tradeoff for this ease of use is that it becomes the application's
responsibility to verify the structure of messages sent/received. There is also
no automatic backwards compatibility like protobuf.

## Getting started

standard_message_codec can be used to encode and decode messages in either Flutter
or pure Dart applications.

<?code-excerpt "readme_excerpts.dart (Encoding)"?>
```dart
void main() {
  final ByteData? data = const StandardMessageCodec().encodeMessage(
    <Object, Object>{'foo': true, 3: 'fizz'},
  );
  print('The encoded message is $data');
}

```
