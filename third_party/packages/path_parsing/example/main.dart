// ignore_for_file: avoid_print

import 'package:path_parsing/path_parsing.dart';

/// A [PathProxy] that dumps Flutter `Path` commands to the console.
class PathPrinter extends PathProxy {
  @override
  void close() {
    print('Path.close();');
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    print('Path.cubicTo($x1, $y1, $x2, $y2, $x3, $y3);');
  }

  @override
  void lineTo(double x, double y) {
    print('Path.lineTo($x, $y);');
  }

  @override
  void moveTo(double x, double y) {
    print('Path.moveTo($x, $y);');
  }
}

void main() {
  const String pathData =
      'M22.1595 3.80852C19.6789 1.35254 16.3807 -4.80966e-07 12.8727 '
      '-4.80966e-07C9.36452 -4.80966e-07 6.06642 1.35254 3.58579 '
      '3.80852C1.77297 5.60333 0.53896 7.8599 0.0171889 10.3343C-0.0738999 '
      '10.7666 0.206109 11.1901 0.64265 11.2803C1.07908 11.3706 1.50711 11.0934 '
      '1.5982 10.661C2.05552 8.49195 3.13775 6.51338 4.72783 4.9391C9.21893 '
      '0.492838 16.5262 0.492728 21.0173 4.9391C25.5082 9.38548 25.5082 16.6202 '
      '21.0173 21.0667C16.5265 25.5132 9.21893 25.5133 4.72805 21.0669C3.17644 '
      '19.5307 2.10538 17.6035 1.63081 15.4937C1.53386 15.0627 1.10252 14.7908 '
      '0.66697 14.887C0.231645 14.983 -0.0427272 15.4103 0.0542205 '
      '15.8413C0.595668 18.2481 1.81686 20.4461 3.5859 22.1976C6.14623 '
      '24.7325 9.50955 26 12.8727 26C16.236 26 19.5991 24.7326 22.1595 '
      '22.1976C27.2802 17.1277 27.2802 8.87841 22.1595 3.80852Z';

  writeSvgPathDataToPath(pathData, PathPrinter());
}
