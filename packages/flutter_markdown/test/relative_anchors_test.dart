import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart';

import 'utils.dart';

void main() => defineTests();

void defineTests() {
  testWidgets('test', (tester) async {
    await tester.pumpWidget(
      boilerplate(
        Markdown(
          extensionSet: ExtensionSet.gitHubFlavored,
          data: '''
Hello we link to the foo chapter heading [here](#foo-chapter)
Hello we link to the foo chapter text foobar [here](#foobar)

We can also link to some a tag.

### Foo chapter

<a id="foobar"></a> Hey this the foobar text that has an "a" tag before.
''',
// Doesn't work:
// <a id="foobar"></a> Hey this the foobar text that has an "a" tag before.
// <a name="foobar"></a> Hey this the foobar text that has an "a" tag before.
// Weil flutter kein HTML wird das einfach drinnen gelassen.
        ),
      ),
    );

    // expect(find.textContaining('Hello.'), findsOneWidget);

    for (final Widget widget in tester.allWidgets) {
      if (widget is RichText) {
        final TextSpan span = widget.text as TextSpan;
        final String text = _extractTextFromTextSpan(span);
        print(text);
      }
    }
  });
  testWidgets('debugging', (tester) async {
    await tester.pumpWidget(
      boilerplate(
        Markdown(
          extensionSet: ExtensionSet.gitHubWeb,
          data: '''
link to [heading below](#first-header-with-code)
# first **header** with `code`
''',
//           data: '''
// # first **header** with `code`
// ## second header
// ### third header
// #### fourth header
// ##### fifth header
// ###### sixth header
// ''',
        ),
      ),
    );

    // expect(find.textContaining('Hello.'), findsOneWidget);

    for (final Widget widget in tester.allWidgets) {
      if (widget is RichText) {
        final TextSpan span = widget.text as TextSpan;
        final String text = _extractTextFromTextSpan(span);
        print(text);
      }
    }
  });

  test('markdown', () {
    final res = markdownToHtml(
      '''
Hello we link to the foo chapter heading [here](#foo-chapter)
Hello we link to the foo chapter text foobar [here](#foobar)

test
---

We can also link to some a tag.

### Foo chapter

<a id="foobar"></a> Hey this the foobar text that has an "a" tag before.
''',
      extensionSet: ExtensionSet.gitHubWeb,
    );

    print(res);
  });
}

String _extractTextFromTextSpan(TextSpan span) {
  String text = span.text ?? '';
  if (span.children != null) {
    for (final TextSpan child in span.children! as Iterable<TextSpan>) {
      text += _extractTextFromTextSpan(child);
    }
  }
  return text;
}
