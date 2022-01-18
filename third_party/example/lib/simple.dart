import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: SvgPicture.asset('assets/flutter_logo.svg', width: 500, height: 500),
      ),
    ),
  ));
}
