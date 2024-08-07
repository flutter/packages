## NEXT

* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 0.3.2+7

* Optimized Socket Binding: Always bind to 0.0.0.0 for simplicity and efficiency.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 0.3.2+6

* Improves links in README.md.

## 0.3.2+5

* Updates `PendingRequest` to be a `base class` for Dart 3.0 compatibility.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.3.2+4

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.3.2+3

* Removes use of `runtimeType.toString()`.
* Updates minimum SDK version to Flutter 3.0.

## 0.3.2+2

* Fixes lints warnings.

## 0.3.2+1

* Migrates from `ui.hash*` to `Object.hash*`.

## 0.3.2

* Updates package description.
* Make [MDnsClient.start] idempotent.

## 0.3.1

* Close IPv6 sockets on [MDnsClient.stop].

## 0.3.0+1

* Removed redundant link in README.md file.

## 0.3.0

* Migrate package to null safety.

## 0.2.2
* Fixes parsing of TXT records. Continues parsing on non-utf8 strings.

## 0.2.1
* Fixes the handling of packets containing non-utf8 strings.

## 0.2.0
* Allow configuration of the port and address the mdns query is performed on.

## 0.1.1

* Fixes [flutter/issue/31854](https://github.com/flutter/flutter/issues/31854) where `decodeMDnsResponse` advanced to incorrect code points and ignored some records.

## 0.1.0

* Initial Open Source release.
* Migrates the dartino-sdk's mDNS client to Dart 2.0 and Flutter's analysis rules
* Breaks from original Dartino code, as it does not use native libraries for macOS and overhauls the `ResourceRecord` class.
