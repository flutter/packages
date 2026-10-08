import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  runApp(
    LiquidGlassWidgets.wrap(
      child: const CupertinoApp(
        title: 'Accessibility Test',
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(brightness: Brightness.dark),
        home: AccessibilityDemo(),
      ),
    ),
  );
}

class AccessibilityDemo extends StatefulWidget {
  const AccessibilityDemo({super.key});

  @override
  State<AccessibilityDemo> createState() => _AccessibilityDemoState();
}

class _AccessibilityDemoState extends State<AccessibilityDemo> {
  bool _switchValue = true;
  double _sliderValue = 0.5;
  int _segmentedValue = 0;
  double _stepperValue = 1.0;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const GlassAppBar(
        title: Text('Keyboard Navigation'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Press TAB to navigate between widgets.\n'
                    'Press SPACE or ENTER to activate them.',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildSection(
                    'Inputs & Search',
                    const Column(
                      children: [
                        GlassTextField(
                          placeholder: 'Type something...',
                        ),
                        SizedBox(height: 16),
                        GlassSearchBar(
                          placeholder: 'Search for items...',
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    'Actions & Toggles',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // GlassButton — icon-centric FAB style
                        Row(
                          children: [
                            GlassButton(
                              icon: const Icon(CupertinoIcons.add),
                              onTap: () {},
                              style: GlassButtonStyle.prominent,
                            ),
                            const SizedBox(width: 16),
                            GlassButton(
                              icon: const Icon(CupertinoIcons.heart),
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            GlassButton(
                              icon: const Icon(CupertinoIcons.share),
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // GlassButtonGroup.icons — labelled actions in a row
                        GlassButtonGroup.icons(
                          items: [
                            GlassButtonGroupItem(
                              label: 'Edit',
                              icon: const Icon(CupertinoIcons.pencil),
                              onTap: () {},
                            ),
                            GlassButtonGroupItem(
                              label: 'Share',
                              icon: const Icon(CupertinoIcons.square_arrow_up),
                              onTap: () {},
                            ),
                            GlassButtonGroupItem(
                              label: 'Delete',
                              icon: const Icon(CupertinoIcons.trash),
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Enable feature'),
                            GlassSwitch(
                              value: _switchValue,
                              onChanged: (v) =>
                                  setState(() => _switchValue = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    'Sliders & Segments',
                    Column(
                      children: [
                        GlassSlider(
                          value: _sliderValue,
                          onChanged: (v) => setState(() => _sliderValue = v),
                        ),
                        const SizedBox(height: 24),
                        GlassSegmentedControl(
                          selectedIndex: _segmentedValue,
                          onSegmentSelected: (v) =>
                              setState(() => _segmentedValue = v),
                          segments: const [
                            GlassSegment(label: 'Option 1'),
                            GlassSegment(label: 'Option 2'),
                            GlassSegment(label: 'Option 3'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    'Lists & Menus',
                    Column(
                      children: [
                        GlassGroupedSection(
                          children: [
                            GlassListTile(
                              leading: const Icon(CupertinoIcons.settings),
                              title: const Text('Settings'),
                              trailing: const Icon(
                                  CupertinoIcons.chevron_forward,
                                  color: CupertinoColors.systemGrey),
                              onTap: () {},
                            ),
                            const GlassDivider(),
                            GlassListTile(
                              leading: const Icon(CupertinoIcons.person),
                              title: const Text('Profile'),
                              trailing: const Icon(
                                  CupertinoIcons.chevron_forward,
                                  color: CupertinoColors.systemGrey),
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        GlassMenu(
                          trigger: GlassButton(
                            icon: const SizedBox.shrink(),
                            label: 'Open Menu',
                            onTap: () {}, // Handled by GlassMenu
                          ),
                          items: [
                            GlassMenuItem(
                              title: 'Option A',
                              icon: const Icon(CupertinoIcons.doc),
                              onTap: () => Navigator.pop(context),
                            ),
                            GlassMenuItem(
                              title: 'Option B',
                              icon: const Icon(CupertinoIcons.folder),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    'Steppers & Chips',
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlassStepper(
                          value: _stepperValue,
                          onChanged: (v) => setState(() => _stepperValue = v),
                        ),
                        GlassChip(
                          label: 'Dismissible',
                          onDeleted: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        content,
        const SizedBox(height: 48),
      ],
    );
  }
}
