import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('Glass Inputs Golden Tests', () {
    testWidgets('Inputs visual compliance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveLiquidGlassLayer(
            settings: const LiquidGlassSettings(),
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo, Colors.teal],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const GlassFormField(
                          label: 'Username',
                          child: GlassTextField(placeholder: 'Enter username'),
                        ),
                        const SizedBox(height: 16),
                        const GlassFormField(
                          label: 'Password',
                          child:
                              GlassPasswordField(placeholder: 'Enter password'),
                        ),
                        const SizedBox(height: 16),
                        const GlassFormField(
                          label: 'Bio',
                          child: GlassTextArea(
                              placeholder: 'Tell us about yourself'),
                        ),
                        const SizedBox(height: 16),
                        GlassFormField(
                          label: 'Role',
                          child: GlassPicker(
                            value: 'Developer',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(height: 16),
                        const GlassFormField(
                          label: 'Error State',
                          errorText: 'This field is required',
                          child: GlassTextField(placeholder: 'Error'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/glass_inputs_collection.png'),
      );
    });
  });
}
