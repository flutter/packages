// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Navigator Integration';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
        debugShowCheckedModeBanner: false,
      );

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        name: 'home',
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            HomeScreen(families: Families.data),
        routes: <GoRoute>[
          GoRoute(
            name: 'family',
            path: 'family/:fid',
            builder: (BuildContext context, GoRouterState state) =>
                FamilyScreenWithAdd(
              family: Families.family(state.params['fid']!),
            ),
            routes: <GoRoute>[
              GoRoute(
                name: 'person',
                path: 'person/:pid',
                builder: (BuildContext context, GoRouterState state) {
                  final Family family = Families.family(state.params['fid']!);
                  final Person person = family.person(state.params['pid']!);
                  return PersonScreen(family: family, person: person);
                },
              ),
              GoRoute(
                name: 'new-person',
                path: 'new-person',
                builder: (BuildContext context, GoRouterState state) {
                  final Family family = Families.family(state.params['fid']!);
                  return NewPersonScreen2(family: family);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// The home screen that shows a list of families.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({required this.families, Key? key}) : super(key: key);

  /// The list of families.
  final List<Family> families;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: ListView(
          children: <Widget>[
            for (final Family f in families)
              ListTile(
                title: Text(f.name),
                onTap: () => context
                    .goNamed('family', params: <String, String>{'fid': f.id}),
              )
          ],
        ),
      );
}

/// The family screen.
class FamilyScreenWithAdd extends StatefulWidget {
  /// Creates a [FamilyScreenWithAdd].
  const FamilyScreenWithAdd({required this.family, Key? key}) : super(key: key);

  /// The family to display.
  final Family family;

  @override
  State<FamilyScreenWithAdd> createState() => _FamilyScreenWithAddState();
}

class _FamilyScreenWithAddState extends State<FamilyScreenWithAdd> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.family.name),
          actions: <Widget>[
            IconButton(
              // onPressed: () => _addPerson1(context), // Navigator-style
              onPressed: () => _addPerson2(context), // GoRouter-style
              tooltip: 'Add Person',
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            for (final Person p in widget.family.people)
              ListTile(
                title: Text(p.name),
                onTap: () => context.go(context.namedLocation(
                  'person',
                  params: <String, String>{
                    'fid': widget.family.id,
                    'pid': p.id
                  },
                  queryParams: <String, String>{'qid': 'quid'},
                )),
              ),
          ],
        ),
      );

  // using a Navigator and a Navigator result
  // ignore: unused_element
  Future<void> _addPerson1(BuildContext context) async {
    final Person? person = await Navigator.push<Person>(
      context,
      MaterialPageRoute<Person>(
        builder: (BuildContext context) =>
            NewPersonScreen1(family: widget.family),
      ),
    );

    if (person != null) {
      setState(() => widget.family.people.add(person));

      // ignore: use_build_context_synchronously
      context.goNamed('person', params: <String, String>{
        'fid': widget.family.id,
        'pid': person.id,
      });
    }
  }

  // using a GoRouter page
  void _addPerson2(BuildContext context) {
    context.goNamed('new-person',
        params: <String, String>{'fid': widget.family.id});
  }
}

/// The person screen.
class PersonScreen extends StatelessWidget {
  /// Creates a [PersonScreen].
  const PersonScreen({required this.family, required this.person, Key? key})
      : super(key: key);

  /// The family this person belong to.
  final Family family;

  /// The person to be displayed.
  final Person person;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(person.name)),
        body: Text('${person.name} ${family.name} is ${person.age} years old'),
      );
}

// returning a Navigator result
/// The screen to add a new person into the family.
class NewPersonScreen1 extends StatefulWidget {
  /// Creates a [NewPersonScreen1].
  const NewPersonScreen1({required this.family, Key? key}) : super(key: key);

  /// The family to be added to.
  final Family family;

  @override
  State<NewPersonScreen1> createState() => _NewPersonScreen1State();
}

class _NewPersonScreen1State extends State<NewPersonScreen1> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _ageController.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        // ask the user if they'd like to adandon their data
        onWillPop: () async => abandonNewPerson(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text('New person for family ${widget.family.name}'),
          ),
          body: Form(
            key: _formKey,
            child: Center(
              child: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'name'),
                      validator: (String? value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a name'
                              : null,
                    ),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'age'),
                      validator: (String? value) => value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null
                          ? 'Please enter an age'
                          : null,
                    ),
                    ButtonBar(children: <Widget>[
                      TextButton(
                        onPressed: () async {
                          // ask the user if they'd like to adandon their data
                          if (await abandonNewPerson(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final Person person = Person(
                              id: 'p${widget.family.people.length + 1}',
                              name: _nameController.text,
                              age: int.parse(_ageController.text),
                            );

                            Navigator.pop(context, person);
                          }
                        },
                        child: const Text('Create'),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<bool> abandonNewPerson(BuildContext context) async {
    final OkCancelResult result = await showOkCancelAlertDialog(
      context: context,
      title: 'Abandon New Person',
      message: 'Are you sure you abandon this new person?',
      okLabel: 'Keep',
      cancelLabel: 'Abandon',
    );

    return result == OkCancelResult.cancel;
  }
}

// adding the result to the data directly (GoRouter page)
/// The screen to add a new person into the family.
class NewPersonScreen2 extends StatefulWidget {
  /// Creates a [NewPersonScreen1].
  const NewPersonScreen2({required this.family, Key? key}) : super(key: key);

  /// The family to display.
  final Family family;

  @override
  State<NewPersonScreen2> createState() => _NewPersonScreen2State();
}

class _NewPersonScreen2State extends State<NewPersonScreen2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _ageController.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        // ask the user if they'd like to adandon their data
        onWillPop: () async => abandonNewPerson(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text('New person for family ${widget.family.name}'),
          ),
          body: Form(
            key: _formKey,
            child: Center(
              child: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'name'),
                      validator: (String? value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a name'
                              : null,
                    ),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'age'),
                      validator: (String? value) => value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null
                          ? 'Please enter an age'
                          : null,
                    ),
                    ButtonBar(children: <Widget>[
                      TextButton(
                        onPressed: () async {
                          // ask the user if they'd like to adandon their data
                          if (await abandonNewPerson(context)) {
                            // Navigator.pop(context) would work here, too
                            context.pop();
                          }
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final Person person = Person(
                              id: 'p${widget.family.people.length + 1}',
                              name: _nameController.text,
                              age: int.parse(_ageController.text),
                            );

                            widget.family.people.add(person);

                            context.goNamed('person', params: <String, String>{
                              'fid': widget.family.id,
                              'pid': person.id,
                            });
                          }
                        },
                        child: const Text('Create'),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<bool> abandonNewPerson(BuildContext context) async {
    final OkCancelResult result = await showOkCancelAlertDialog(
      context: context,
      title: 'Abandon New Person',
      message: 'Are you sure you abandon this new person?',
      okLabel: 'Keep',
      cancelLabel: 'Abandon',
    );

    return result == OkCancelResult.cancel;
  }
}
