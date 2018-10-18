// Support code to generate the hex-lists in test/decode_test.dart from
// a hex-stream.
void formatHexStream(String hexStream) {
  String s = '';
  for (int i = 0; i < hexStream.length / 2; i++) {
    if (s.isNotEmpty) {
      s += ', ';
    }
    s += '0x';
    final String x = hexStream.substring(i * 2, i * 2 + 2);
    s += x;
    if (((i + 1) % 8) == 0) {
      s += ',';
      print(s);
      s = '';
    }
  }
  if (s.isNotEmpty) {
    print(s);
  }
}

// Support code for generating the hex-lists in test/decode_test.dart.
void hexDumpList(List<int> package) {
  String s = '';
  for (int i = 0; i < package.length; i++) {
    if (s.isNotEmpty) {
      s += ', ';
    }
    s += '0x';
    final String x = package[i].toRadixString(16);
    if (x.length == 1) {
      s += '0';
    }
    s += x;
    if (((i + 1) % 8) == 0) {
      s += ',';
      print(s);
      s = '';
    }
  }
  if (s.isNotEmpty) {
    print(s);
  }
}
