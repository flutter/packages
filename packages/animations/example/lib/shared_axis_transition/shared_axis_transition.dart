import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// The demo page for [SharedAxisPageTransitionsBuilder].
class SharedAxisTransitionDemo extends StatefulWidget {
  @override
  _SharedAxisTransitionDemoState createState() {
    return _SharedAxisTransitionDemoState();
  }
}

class _SharedAxisTransitionDemoState extends State<SharedAxisTransitionDemo> {
  final Key coursePageKey = const Key('Course Page');
  final Key signInPageKey = const Key('Sign In Page');

  SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal;
  bool isLoggedIn = false;

  void updateTransitionType(SharedAxisTransitionType newType) {
    setState(() {
      transitionType = newType;
    });
  }

  void toggleLoginStatus() {
    setState(() {
      isLoggedIn = !isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(title: const Text('Shared Axis Transition')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ListView(
            children: <Widget>[
              SizedBox(
                height: constraints.maxHeight - 120,
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverse: isLoggedIn,
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                  ) {
                    return SharedAxisTransition(
                      child: child,
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: transitionType,
                    );
                  },
                  child: isLoggedIn ? _CoursePage() : _SignInPage(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: isLoggedIn ? toggleLoginStatus : null,
                      textColor: Theme.of(context).colorScheme.primary,
                      child: const Text('BACK'),
                    ),
                    RaisedButton(
                      onPressed: isLoggedIn ? null : toggleLoginStatus,
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      disabledColor: Colors.black12,
                      child: const Text('NEXT'),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 2.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio<SharedAxisTransitionType>(
                    value: SharedAxisTransitionType.horizontal,
                    groupValue: transitionType,
                    onChanged: (SharedAxisTransitionType newValue) {
                      updateTransitionType(newValue);
                    },
                  ),
                  const Text('X'),
                  Radio<SharedAxisTransitionType>(
                    value: SharedAxisTransitionType.vertical,
                    groupValue: transitionType,
                    onChanged: (SharedAxisTransitionType newValue) {
                      updateTransitionType(newValue);
                    },
                  ),
                  const Text('Y'),
                  Radio<SharedAxisTransitionType>(
                    value: SharedAxisTransitionType.scaled,
                    groupValue: transitionType,
                    onChanged: (SharedAxisTransitionType newValue) {
                      updateTransitionType(newValue);
                    },
                  ),
                  const Text('Z'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CoursePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
        Text(
          'Streamling your courses',
          style: Theme.of(context).textTheme.headline,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
        Text(
          'Bundled categories appear as groups in your feed.'
          'You can always change this later',
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const _CourseSwitch(course: 'Arts & Crafts'),
        const _CourseSwitch(course: 'Business'),
        const _CourseSwitch(course: 'Illustration'),
        const _CourseSwitch(course: 'Design'),
        const _CourseSwitch(course: 'Culinary'),
      ],
    );
  }
}

class _CourseSwitch extends StatefulWidget {
  const _CourseSwitch({
    this.course,
  });

  final String course;

  @override
  __CourseSwitchState createState() => __CourseSwitchState();
}

class __CourseSwitchState extends State<_CourseSwitch> {
  bool value = true;

  @override
  Widget build(BuildContext context) {
    final String subtitle = value ? 'Bundled' : 'Shown Individually';
    return SwitchListTile(
      title: Text(widget.course),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (bool newValue) {
        setState(() {
          value = newValue;
        });
      },
    );
  }
}

class _SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(padding: EdgeInsets.symmetric(vertical: 35.0)),
        const CircleAvatar(
          radius: 28.0,
          backgroundColor: Colors.black54,
          child: Text(
            'DP',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
        Text(
          'Hi David Park',
          style: Theme.of(context).textTheme.headline,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
        Text(
          'Sign in with your account',
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: 15.0,
                right: 15.0,
                bottom: 10.0,
              ),
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.visibility,
                    size: 20,
                    color: Colors.black54,
                  ),
                  isDense: true,
                  labelText: 'Email or phone number',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: FlatButton(
                onPressed: () {},
                textColor: Theme.of(context).colorScheme.primary,
                child: const Text('FORGOT EMAIL?'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: FlatButton(
                onPressed: () {},
                textColor: Theme.of(context).colorScheme.primary,
                child: const Text('CREATE ACCOUNT'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
