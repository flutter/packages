import 'package:flutter/material.dart';
import 'package:mustache_template/mustache_template.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mustache Template Demo',
      home: MustacheDemoPage(),
    );
  }
}

class MustacheDemoPage extends StatelessWidget {
  const MustacheDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion basic-usage
    final greetingTemplate = Template('Hello, {{name}}!');
    final greeting = greetingTemplate.renderString({'name': 'Flutter'});
    // #enddocregion basic-usage

    // #docregion section
    final sectionTemplate = Template(
      '{{#names}}{{lastname}}, {{firstname}} | {{/names}}'
          '{{^names}}No names found.{{/names}}',
    );
    final withNames = sectionTemplate.renderString({
      'names': [
        {'firstname': 'Hiba', 'lastname': 'C'},
        {'firstname': 'Jihed', 'lastname': 'B'},
      ],
    });
    final withoutNames = sectionTemplate.renderString({'names': []});
    // #enddocregion section

    // #docregion lambda
    final lambdaTemplate = Template('{{#bold}}{{text}}{{/bold}}');
    final lambdaOutput = lambdaTemplate.renderString({
      'text': 'Hello',
      'bold': (LambdaContext ctx) => '<b>${ctx.renderString()}</b>',
    });
    // #enddocregion lambda

    return Scaffold(
      appBar: AppBar(title: const Text('Mustache Template Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _SectionCard(title: 'Basic Variable', output: greeting),
            _SectionCard(title: 'Section (with data)', output: withNames),
            _SectionCard(title: 'Inverted Section (empty)', output: withoutNames),
            _SectionCard(title: 'Lambda', output: lambdaOutput),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.output});

  final String title;
  final String output;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(output),
          ],
        ),
      ),
    );
  }
}