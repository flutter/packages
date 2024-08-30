# url\_launcher\_web

The web implementation of [`url_launcher`][1].

## Usage

This package is [endorsed][2], which means you can simply use `url_launcher`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

[1]: https://pub.dev/packages/url_launcher
[2]: https://flutter.dev/to/endorsed-federated-plugin

## Limitations on the Web platform

### A launch needs to be triggered by a user action

Web browsers prevent launching URLs in a new tab/window, unless triggered by a
user action (e.g. a button click).

Even if a user triggers a launch through a button click, if there is a delay due
to awaiting a Future before the launch, the browser may still block it. This is
because the browser might perceive the launch as not being a direct result of
user interaction, particularly if the Future takes too long to complete.

In such cases, you can use the `webOnlyWindowName` parameter, setting it to
`_self`, to open the URL within the current tab. Another approach is to ensure
that the `uri` is synchronously ready.

Read more: MDN > [Transient activation](https://developer.mozilla.org/en-US/docs/Glossary/Transient_activation).

### Method `launchUrl` always returns `true` for allowed schemes

The `launchUrl` method always returns `true` on the web platform for allowed
schemes. This is because URLs are opened in a new window using the `noopener`
window feature. When the `noopener` feature is used, the browser does not 
return any information that can be used to determine if the link was 
successfully opened.

Read more: MDN > [window.open](https://developer.mozilla.org/en-US/docs/Web/API/Window/open#noopener).