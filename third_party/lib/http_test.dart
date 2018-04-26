import 'dart:async';
import 'dart:io';
import 'dart:convert';

const List<String> uriNames = const [
  'http://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg',
  'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg'
];

main() async {
  uriNames.forEach((uri) async {
    String ret = await loadNetworkAsset(uri, null);
    print(ret);
  });
}

Future<String> loadNetworkAsset(
  String uri,
  Map<String, String> headers,
) async {
  final Uri resolved = Uri.base.resolve(uri);
  print('trying $resolved');
  final HttpClientRequest request = await new HttpClient().getUrl(resolved);
  headers?.forEach((String name, String value) {
    request.headers.add(name, value);
  });
  request.headers.removeAll(HttpHeaders.ACCEPT_ENCODING);
  final HttpClientResponse response = await request.close();
  if (response.statusCode != HttpStatus.OK) {
    throw new Exception(
        'HTTP request failed, statusCode: ${response?.statusCode}, $resolved');
  }

  final String xml = await consolidateHttpClientResponse(response);
  if (xml.length == 0)
    throw new Exception('NetworkImage is an empty file: $resolved');

  return xml;
}

Future<String> consolidateHttpClientResponse(HttpClientResponse response) {
  final Completer<String> completer = new Completer<String>.sync();
  final StringBuffer buffer = new StringBuffer();

  response.transform(UTF8.decoder).listen((String chunk) {
    buffer.write(chunk);
    //print('CHUNK: $chunk');
  }, onDone: () {
    print('DONE');
    completer.complete(buffer.toString());
  }, onError: completer.completeError, cancelOnError: true);

  return completer.future;
}
