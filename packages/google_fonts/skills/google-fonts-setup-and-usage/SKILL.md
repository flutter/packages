---
name: google-fonts-setup-and-usage
description: Set up and use the google_fonts package to apply Google Fonts to TextStyles and TextThemes in Flutter via runtime HTTP fetching or bundled assets.
---

# Setting Up and Using google_fonts

The `google_fonts` package provides direct access to over 1,000 font families from [fonts.google.com](https://fonts.google.com/). It supports automatic HTTP fetching and device caching during development, as well as offline asset bundling for production releases.

## 1. Installation

Add `google_fonts` to your project's `pubspec.yaml`:

```bash
flutter pub add google_fonts
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  google_fonts: ^8.2.1
```

## 2. Platform and Production Configuration

### macOS Network Entitlement (For Runtime HTTP Fetching)
When running on macOS and fetching fonts over HTTP, enable outgoing network connections in `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

### Bundling Font Assets for Offline / Release Builds
To bundle fonts into your app binary so they work offline without HTTP requests:
1. Download the `.ttf` or `.otf` files for the weights you use from Google Fonts (do not rename the files).
2. Place them in an asset directory (e.g., `google_fonts/`).
3. Declare the directory under `flutter: assets:` in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - google_fonts/
```

4. Optionally disable runtime HTTP fetching in `main()` to ensure only bundled fonts are used:

```dart
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}
```

### Registering Font Licenses
Include the font's license file (e.g., `OFL.txt`) in your assets and register it with Flutter's `LicenseRegistry`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });
  runApp(const MyApp());
}
```

## 3. Usage and API Examples

Import the package in your Dart code:

```dart
import 'package:google_fonts/google_fonts.dart';
```

### Applying Fonts to Individual `Text` Widgets

```dart
// Direct static font helper
Text(
  'Hello with Lato',
  style: GoogleFonts.lato(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
  ),
);

// Dynamic font loading by family name string
Text(
  'Dynamic Font Loading',
  style: GoogleFonts.getFont('Roboto Mono', fontSize: 16),
);

// Wrapping an existing TextStyle from Theme
Text(
  'Themed Headline',
  style: GoogleFonts.poppins(
    textStyle: Theme.of(context).textTheme.headlineMedium,
    color: Colors.deepPurple,
  ),
);
```

### Applying a Font to the Entire App `TextTheme`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );

    return MaterialApp(
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}
```

### Preventing Visual Font Swapping (`pendingFonts`)

Wait for pending font downloads to complete before rendering text using `GoogleFonts.pendingFonts()`:

```dart
FutureBuilder<List<void>>(
  future: GoogleFonts.pendingFonts(<TextStyle>[
    GoogleFonts.montserrat(),
    GoogleFonts.firaCode(),
  ]),
  builder: (BuildContext context, AsyncSnapshot<List<void>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const CircularProgressIndicator();
    }
    return Text('Fonts loaded cleanly!', style: GoogleFonts.montserrat());
  },
);
```
