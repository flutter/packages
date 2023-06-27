import 'dart:io';

import 'package:wasm/wasm.dart';

import 'api.dart';

class NetworkImplementation extends Network {
  @override
  Future<List<int>> get(String url) async {
    final HttpClientResponse client = await (await HttpClient().getUrl(Uri.parse(url))).close();
    return await client.expand((List<int> chunk) => chunk).toList();
  }
}