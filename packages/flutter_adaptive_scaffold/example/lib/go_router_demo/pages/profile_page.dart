import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const String path = '/profile';
  static const String name = 'Profile';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
