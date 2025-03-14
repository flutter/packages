import 'package:meta/meta.dart';

@immutable
class WebHistoryItem {
  ///Original url of this history item.
  final Uri? originalUrl;

  ///Document title of this history item.
  final String title;

  ///Url of this history item.
  final Uri url;

  ///0-based position index in the back-forward [WebHistory.list].
  final int? index;

  ///Position offset respect to the currentIndex of the back-forward [WebHistory.list].
  final int? offset;

  WebHistoryItem(this.title, this.url, {this.originalUrl, this.index, this.offset});
}