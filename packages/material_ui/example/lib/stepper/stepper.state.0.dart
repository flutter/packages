// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Step.state].

void main() => runApp(const StepperStateExampleApp());

class StepperStateExampleApp extends StatelessWidget {
  const StepperStateExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Stepper state Sample')),
        body: const Center(child: StepperStateExample()),
      ),
    );
  }
}

class StepperStateExample extends StatefulWidget {
  const StepperStateExample({super.key});

  @override
  State<StepperStateExample> createState() => _StepperStateExampleState();
}

class _StepperStateExampleState extends State<StepperStateExample> {
  int _currentStep = 0;

  bool _accountCreated = false;
  bool _profileCompleted = false;
  bool _setupCompleted = false;

  List<Step> get _steps => [
    Step(
      title: const Text('Create account title'),
      content: ElevatedButton(
        onPressed: () {
          setState(() {
            _accountCreated = true;
          });
        },
        child: const Text('Create account button'),
      ),
      state: _accountCreated ? StepState.complete : StepState.indexed,
      isActive: true,
    ),
    Step(
      title: const Text('Complete profile'),
      content: ElevatedButton(
        onPressed: _accountCreated
            ? () {
                setState(() {
                  _profileCompleted = true;
                });
              }
            : null,
        child: const Text('Complete profile button'),
      ),
      state: _profileCompleted ? StepState.complete : StepState.indexed,
      isActive: _accountCreated,
    ),
    Step(
      title: const Text('Finish setup'),
      content: ElevatedButton(
        onPressed: _profileCompleted
            ? () {
                setState(() {
                  _setupCompleted = true;
                });
              }
            : null,
        child: const Text('Finish setup button'),
      ),
      state: _setupCompleted ? StepState.complete : StepState.indexed,
      isActive: _profileCompleted,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      steps: _steps,
      onStepTapped: (step) {
        setState(() {
          _currentStep = step;
        });
      },
      onStepContinue: () {
        if (_currentStep < _steps.length - 1) {
          setState(() {
            _currentStep++;
          });
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
          });
        }
      },
    );
  }
}
// #endregion body
