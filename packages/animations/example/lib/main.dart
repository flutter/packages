import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:animations/animations.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData.from(
    colorScheme: const ColorScheme.light(),
  ).copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    ),
  ),
  home: _TransitionsHomePage(),
));

class _TransitionsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Transitions')),
      body: Column(
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
            leading: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Colors.black54,
                ),
              ),
              child: Icon(
                Icons.play_arrow,
                size: 35,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => _SharedAxisTransitionDemo(),
                ),
              );
            },
            title: const Text('Shared Axis'),
            subtitle: const Text('Page transition where outgoing and incoming elements share a fade transition'),
          ),
        ],
      ),
    );
  }
}

class _SharedAxisTransitionDemo extends StatefulWidget {
  @override
  __SharedAxisTransitionDemoState createState() => __SharedAxisTransitionDemoState();
}

class __SharedAxisTransitionDemoState extends State<_SharedAxisTransitionDemo> {
  SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(),
      ).copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: SharedAxisPageTransitionsBuilder(
              transitionType: transitionType,
            ),
          },
        ),
      ),
      home: _SignInPage(
        transitionType: transitionType,
        updateTransitionType: updateTransitionType,
      ),
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/') {
          return MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return _SignInPage(
                transitionType: transitionType,
                updateTransitionType: updateTransitionType,
              );
            }
          );
        } else if (settings.name == '/coursepage') {
          return MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return _CoursePage(
                transitionType: transitionType,
                updateTransitionType: updateTransitionType,
              );
            }
          );
        }
        return null;
      },
    );
  }

  void updateTransitionType(SharedAxisTransitionType newType) {
    setState(() {
      transitionType = newType;
    });
  }
}

class _CoursePage extends StatelessWidget {
  const _CoursePage({
    this.transitionType,
    this.updateTransitionType,
  });

  final SharedAxisTransitionType transitionType;

  final Function updateTransitionType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared Axis Transition')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ListView(
            children: <Widget>[
              SizedBox(
                height: constraints.maxHeight - 120,
                child: Column(
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('BACK'),
                    ),
                    const RaisedButton(
                      onPressed: null,
                      child: Text('NEXT'),
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
    return SwitchListTile(
      title: Text(widget.course),
      subtitle: value ? const Text('Bundled') : const Text('Shown Individually'),
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
  const _SignInPage({
    this.transitionType,
    this.updateTransitionType,
  });

  final SharedAxisTransitionType transitionType;

  final Function updateTransitionType;

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
                child: Column(
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.symmetric(vertical: 35.0)),
                    CircleAvatar(
                      radius: 28.0,
                      backgroundColor: Colors.black54,
                      child: const Text(
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
                            child: const Text('FORGOT EMAIL?'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: FlatButton(
                            onPressed: () {},
                            child: const Text('CREATE ACCOUNT'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const FlatButton(
                      onPressed: null,
                      child: Text('BACK'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/coursepage',
                        );
                      },
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
