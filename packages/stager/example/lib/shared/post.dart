import 'user.dart';

/// A single tweet-like entry.
class Post {
  final int id;
  final String text;
  final User author;
  final DateTime time;

  Post({
    required this.id,
    required this.text,
    required this.author,
    required this.time,
  });

  static List<Post> fakePosts({User? user}) => List.generate(
        20,
        (index) => Post(
          id: index + 1,
          text: 'Post ${index + 1}',
          author: user ?? User.fakeUser(id: index + 1),
          time: DateTime.now(),
        ),
      );
}
