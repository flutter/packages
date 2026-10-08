import 'package:flutter/cupertino.dart';

import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class InputsPage extends StatelessWidget {
  const InputsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveLiquidGlassLayer(
      // Widgets inside use LightweightLiquidGlass (standard) or full shader (premium)
      settings: RecommendedGlassSettings.input,
      child: GlassScaffold(
        backgroundColor: const Color(0x00000000),
        appBar: GlassAppBar(
          title: Text(
            'Inputs',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label.resolveFrom(context)),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forms & Inputs',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'New iOS 26 style input primitives.',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label
                      .resolveFrom(context)
                      .withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 32),

              // Form Example
              _SectionHeader('Input Form'),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemFill.resolveFrom(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GlassFormField(
                        label: 'Account Email',
                        child: GlassTextField(
                          placeholder: 'example@email.com',
                          keyboardType: TextInputType.emailAddress,
                          useOwnLayer: true,
                          prefixIcon: Icon(CupertinoIcons.mail,
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                              size: 20),
                        ),
                      ),
                      SizedBox(height: 16),
                      const GlassFormField(
                        label: 'Password',
                        helperText: 'Must be at least 8 characters',
                        child: GlassPasswordField(),
                      ),
                      SizedBox(height: 16),
                      GlassFormField(
                        label: 'Role',
                        child: GlassPicker(
                          value: 'Administrator',
                          icon: Icon(CupertinoIcons.briefcase),
                          useOwnLayer: true, // Demo specific layer usage
                          quality: GlassQuality.premium,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Text Area Example
              _SectionHeader('Multi-line Text'),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemFill.resolveFrom(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: GlassFormField(
                    label: 'Bio / Description',
                    child: GlassTextArea(
                      placeholder: 'Write a short description...',
                      minLines: 4,
                      useOwnLayer: true,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Search Bar Example
              _SectionHeader('Search'),
              const GlassSearchBar(
                placeholder: 'Search documentation...',
              ),
              SizedBox(height: 16),

              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }
}
