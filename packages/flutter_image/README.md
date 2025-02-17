# Image utilities for Flutter

## To be discontinued

**This project will be discontinued on April 30, 2025**, and will not receive further updates after that point. Community members interested in collaborating on a community-maintained fork can coordinate in [this issue](https://github.com/flutter/flutter/issues/162964).

---

## NetworkImageWithRetry

Use `NetworkImageWithRetry` instead of `Image.network` to load images from the
network with a retry mechanism.

Example:

<?code-excerpt "example/lib/readme_excerpts.dart (NetworkImageWithRetry)"?>
```dart
const Image avatar = Image(
  image: NetworkImageWithRetry('http://example.com/avatars/123.jpg'),
);
```

The retry mechanism may be customized by supplying a custom `FetchStrategy`
function. `FetchStrategyBuilder` is a utility class that helps building fetch
strategy functions.

## Features and bugs

Please file feature requests and bugs at https://github.com/flutter/flutter/issues.
