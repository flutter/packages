---
name: url-launcher-web-setup-and-usage
description: Set up and configure url_launcher_web, the Web implementation of Flutter's url_launcher plugin. Covers endorsed usage, popup blocker transient activation rules, webOnlyWindowName targets (_self vs _blank), and Link widget integration.
---

# Setting Up and Using url_launcher_web

`url_launcher_web` is the endorsed Web platform implementation of the Flutter [`url_launcher`](https://pub.dev/packages/url_launcher) plugin. It uses browser APIs (`window.open`) and provides the web implementation for the `Link` widget.

## 1. Installation and Setup

Because `url_launcher_web` is an endorsed federated plugin implementation, adding `url_launcher` to your `pubspec.yaml` automatically includes it when compiling for Web:

```yaml
dependencies:
  url_launcher: ^6.3.2
```

If you need to depend on `url_launcher_web` directly in your `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.3.2
  url_launcher_web: ^2.4.3
```

## 2. Platform-Specific Behavior and Limitations

### Transient User Activation and Popup Blockers

Modern web browsers block `window.open` calls that open a new tab or window (`_blank`) unless triggered directly by a synchronous user gesture (transient activation, such as a button click).

If your code awaits an asynchronous operation (like an HTTP request or database lookup) before calling `launchUrl`, the browser may lose the user activation context and block the new tab. To avoid popup blockers:
1. Compute or fetch the target URL before the user clicks the button so `launchUrl` runs immediately in the `onPressed` handler.
2. Alternatively, pass `webOnlyWindowName: '_self'` to open the URL in the current browser tab instead of a new tab.
3. Use the `Link` widget from `package:url_launcher/link.dart`, which renders a native HTML `<a>` anchor element on the web.

### Return Value of `launchUrl` on Web

On the web, `launchUrl` opens new windows using the `noopener` window feature for security. Because `noopener` prevents the opener from inspecting the newly created window reference, `launchUrl` always returns `true` for allowed schemes (`http`, `https`, `mailto`, `tel`, `sms`). Note that `javascript:` URLs are explicitly disallowed.

## 3. Usage and API Examples

### Opening URLs in New vs. Current Tab (`webOnlyWindowName`)

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openInNewTab() async {
  final Uri url = Uri.parse('https://flutter.dev');
  // Opens in a new tab ('_blank' is default on web)
  await launchUrl(url, webOnlyWindowName: '_blank');
}

Future<void> openInCurrentTabAfterAsyncWork() async {
  // If awaiting a Future before launching, use '_self' to avoid popup blockers
  await Future<void>.delayed(const Duration(milliseconds: 500));
  final Uri url = Uri.parse('https://flutter.dev');
  await launchUrl(url, webOnlyWindowName: '_self');
}
```

### Using the `Link` Widget for Native Web Semantics

For the best web user experience (right-click to copy link, middle-click to open in background tab, SEO, and accessibility), use the `Link` widget from `package:url_launcher/link.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class DocsLinkButton extends StatelessWidget {
  const DocsLinkButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.parse('https://docs.flutter.dev'),
      target: LinkTarget.blank,
      builder: (BuildContext context, FollowLink? followLink) {
        return ElevatedButton(
          onPressed: followLink,
          child: const Text('Open Flutter Docs'),
        );
      },
    );
  }
}
```

### Direct Platform Registration

If registering `UrlLauncherPlugin` manually in custom web test harnesses:

```dart
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:url_launcher_web/url_launcher_web.dart';

void registerWebLauncher(Registrar registrar) {
  UrlLauncherPlugin.registerWith(registrar);
}
```
