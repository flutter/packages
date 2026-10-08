import 'package:liquid_glass_widgets/widgets/overlays/glass_dialog.dart';
import 'package:liquid_glass_widgets/widgets/overlays/glass_sheet.dart';
import 'package:flutter/material.dart';

import '../shared/test_helpers.dart';

void main() {
  goldenTest(
    'GlassDialog renders correctly',
    fileName: 'glass_dialog',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'title_and_message',
          child: buildWithGradientBackground(
            GlassDialog(
              title: 'Confirm',
              message: 'Are you sure you want to continue?',
              actions: [
                GlassDialogAction(
                  label: 'Cancel',
                  onPressed: () {},
                ),
                GlassDialogAction(
                  label: 'OK',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'single_action',
          child: buildWithGradientBackground(
            GlassDialog(
              title: 'Success',
              message: 'Your changes have been saved.',
              actions: [
                GlassDialogAction(
                  label: 'OK',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'three_actions',
          child: buildWithGradientBackground(
            GlassDialog(
              title: 'Save Changes?',
              message: 'You have unsaved changes.',
              actions: [
                GlassDialogAction(
                  label: "Don't Save",
                  onPressed: () {},
                ),
                GlassDialogAction(
                  label: 'Cancel',
                  onPressed: () {},
                ),
                GlassDialogAction(
                  label: 'Save',
                  isPrimary: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'destructive_action',
          child: buildWithGradientBackground(
            GlassDialog(
              title: 'Delete Item?',
              message: 'This action cannot be undone.',
              actions: [
                GlassDialogAction(
                  label: 'Cancel',
                  onPressed: () {},
                ),
                GlassDialogAction(
                  label: 'Delete',
                  isDestructive: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'GlassSheet renders correctly',
    fileName: 'glass_sheet',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      scenarioConstraints: testScenarioConstraints,
      children: [
        GoldenTestScenario(
          name: 'with_drag_indicator',
          child: buildWithGradientBackground(
            const GlassSheet(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sheet Title',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sheet content goes here',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'without_drag_indicator',
          child: buildWithGradientBackground(
            const GlassSheet(
              showDragIndicator: false,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Sheet without drag indicator',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
