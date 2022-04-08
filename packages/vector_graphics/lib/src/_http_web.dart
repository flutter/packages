// This lint is currently broken for packages that say they support web.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';

/// Fetches an HTTP resource from the specified [url] using the specified [headers].
Future<Uint8List> httpGet(Uri uri, {Map<String, String>? headers}) async {
  final HttpRequest request = await HttpRequest.request(
    uri.toString(),
    requestHeaders: headers,
  );
  request.responseType = 'arraybuffer';
  if (request.response is Uint8List) {
    return request.response as Uint8List;
  } else {
    return Uint8List.fromList(request.response as List<int>);
  }
}
