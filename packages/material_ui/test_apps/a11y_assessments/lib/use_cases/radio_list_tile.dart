// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';
import '../utils.dart';
import 'use_cases.dart';

class RadioListTileUseCase extends UseCase {
  RadioListTileUseCase();

  @override
  String get name => 'RadioListTile';

  @override
  String get route => '/radio-list-tile';

  @override
  List<Tag> get tags => <Tag>[Tag.batch1, Tag.core];

  @override
  Widget build(BuildContext context) => _MainWidget();
}

class _MainWidget extends StatefulWidget {
  @override
  State<_MainWidget> createState() => _MainWidgetState();
}

enum SingingCharacter { lafayette, jefferson }

class _MainWidgetState extends State<_MainWidget> {
  SingingCharacter _value = SingingCharacter.lafayette;

  void _onChanged(SingingCharacter? value) {
    setState(() {
      _value = value!;
    });
  }

  String pageTitle = getUseCaseName(RadioListTileUseCase());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Semantics(headingLevel: 1, child: Text('$pageTitle Demo'))),
      body: Semantics(
        label: 'Singing character',
        child: RadioGroup<SingingCharacter>(
          groupValue: _value,
          onChanged: _onChanged,
          child: ListView(
            children: const <Widget>[
              RadioListTile<SingingCharacter>(
                title: Text('Lafayette'),
                value: SingingCharacter.lafayette,
              ),
              RadioListTile<SingingCharacter>(
                title: Text('Jefferson'),
                value: SingingCharacter.jefferson,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
