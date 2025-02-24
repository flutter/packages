## 2.4.6

* Ensures that platform messages on background queues are handled in order.

## 2.4.5

* Bumps gradle-plugin to 2.1.10.

## 2.4.4

* Restores the behavior of throwing a `TypeError` when calling `getStringList`
  on a value stored with `setString`.

## 2.4.3

* Migrates `List<String>` value encoding to JSON.

## 2.4.2

* Bumps gradle-plugin to 2.1.0.

## 2.4.1

* Bumps kotlin version to 1.9.10 androidx.datastore:datastore from 1.0.0 to 1.1.1.

## 2.4.0

* Adds `SharedPreferences` support within `SharedPreferencesAsyncAndroid` API.

## 2.3.4

* Restrict types when decoding preferences.

## 2.3.3

* Updates Java compatibility version to 11.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 2.3.2

* Bumps `com.android.tools.build:gradle` from 7.2.2 to 8.5.1.

## 2.3.1

* Fixes `getStringList` returning immutable list.

## 2.3.0

* Adds new `SharedPreferencesAsyncAndroid` API.

## 2.2.4

* Updates lint checks to ignore NewerVersionAvailable.

## 2.2.3

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 2.2.2

* Updates minSdkVersion to 19.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.
* Updates compileSdk version to 34.
* Updates mockito to 5.2.0.

## 2.2.1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.
* Deletes deprecated splash screen meta-data element.

## 2.2.0

* Adds `clearWithParameters` and `getAllWithParameters` methods.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.1.4

* Fixes compatibility with AGP versions older than 4.2.

## 2.1.3

* Adds a namespace for compatibility with AGP 8.0.

## 2.1.2

* Sets the required Java compile version to 1.8 for new features used in 2.1.1.

## 2.1.1

* Updates minimum Flutter version to 3.0.
* Converts implementation to Pigeon.

## 2.1.0

* Adds `getAllWithPrefix` and `clearWithPrefix` methods.

## 2.0.17

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.
* Updates compileSdkVersion to 33.

## 2.0.16

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.0.15

* Updates code for stricter lint checks.

## 2.0.14

* Fixes typo in `SharedPreferencesAndroid` docs.
* Updates code for `no_leading_underscores_for_local_identifiers` lint.

## 2.0.13

* Updates gradle to 7.2.2.
* Updates minimum Flutter version to 2.10.

## 2.0.12

* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.0.11

* Switches to an in-package method channel implementation.

## 2.0.10

* Removes dependency on `meta`.

## 2.0.9

* Updates compileSdkVersion to 31.

## 2.0.8

* Split from `shared_preferences` as a federated implementation.
