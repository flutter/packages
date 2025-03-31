// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class IndoorLevelPage extends GoogleMapExampleAppPage {
  const IndoorLevelPage({Key? key})
      : super(const Icon(Icons.elevator), 'Indoor Levels', key: key);

  @override
  Widget build(BuildContext context) {
    return const IndoorLevelWidget();
  }
}

class IndoorLevelWidget extends StatefulWidget {
  const IndoorLevelWidget({super.key});
  @override
  State createState() => IndoorLevelWidgetState();
}

class IndoorLevelWidgetState extends State<IndoorLevelWidget> {
  IndoorLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(_selectedLevel == null
            ? 'No floor selected'
            : 'Selected floor name: ${_selectedLevel?.name}\nSelected floor shortName: : ${_selectedLevel?.shortName}'),
        SizedBox(
          height: 300.0,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            onActiveLevelChanged: (IndoorLevel? selectedLevel) {
              setState(() {
                _selectedLevel = selectedLevel;
              });
            },
            initialCameraPosition: const CameraPosition(
                target: LatLng(36.10741826429339, -115.17673087814264),
                zoom: 18),
          ),
        ),
      ],
    );
  }
}
