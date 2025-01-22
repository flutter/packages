import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  enableFlutterDriverExtension();
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/wikimedia/Ghostscript_Tiger.svg'),
          const CircularProgressIndicator(),
        ],
      ),
    ),
  );
}
