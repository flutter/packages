// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// Person data class.
class Person {
  /// Creates a [Person].
  Person({required this.id, required this.name, required this.age});

  /// The id of the person.
  final String id;

  /// The name of the person.
  final String name;

  /// The age of the person.
  final int age;
}

/// Family data class.
class Family {
  /// Creates a [Family].
  Family({required this.id, required this.name, required this.people});

  /// The id of the family.
  final String id;

  /// The name of the family.
  final String name;

  /// The list of [Person]s in the family.
  final List<Person> people;

  /// Gets the [Person] with the given id in this family.
  Person person(String pid) => people.singleWhere(
        (Person p) => p.id == pid,
        orElse: () => throw Exception('unknown person $pid for family $id'),
      );
}

/// The mock of families data.
class Families {
  Families._();

  /// The data.
  static final List<Family> data = <Family>[
    Family(
      id: 'f1',
      name: 'Sells',
      people: <Person>[
        Person(id: 'p1', name: 'Chris', age: 52),
        Person(id: 'p2', name: 'John', age: 27),
        Person(id: 'p3', name: 'Tom', age: 26),
      ],
    ),
    Family(
      id: 'f2',
      name: 'Addams',
      people: <Person>[
        Person(id: 'p1', name: 'Gomez', age: 55),
        Person(id: 'p2', name: 'Morticia', age: 50),
        Person(id: 'p3', name: 'Pugsley', age: 10),
        Person(id: 'p4', name: 'Wednesday', age: 17),
      ],
    ),
    Family(
      id: 'f3',
      name: 'Hunting',
      people: <Person>[
        Person(id: 'p1', name: 'Mom', age: 54),
        Person(id: 'p2', name: 'Dad', age: 55),
        Person(id: 'p3', name: 'Will', age: 20),
        Person(id: 'p4', name: 'Marky', age: 21),
        Person(id: 'p5', name: 'Ricky', age: 22),
        Person(id: 'p6', name: 'Danny', age: 23),
        Person(id: 'p7', name: 'Terry', age: 24),
        Person(id: 'p8', name: 'Mikey', age: 25),
        Person(id: 'p9', name: 'Davey', age: 26),
        Person(id: 'p10', name: 'Timmy', age: 27),
        Person(id: 'p11', name: 'Tommy', age: 28),
        Person(id: 'p12', name: 'Joey', age: 29),
        Person(id: 'p13', name: 'Robby', age: 30),
        Person(id: 'p14', name: 'Johnny', age: 31),
        Person(id: 'p15', name: 'Brian', age: 32),
      ],
    ),
  ];

  /// Looks up a family in the data.
  static Family family(String fid) => data.family(fid);
}

extension on List<Family> {
  Family family(String fid) => singleWhere(
        (Family f) => f.id == fid,
        orElse: () => throw Exception('unknown family $fid'),
      );
}

/// The login information.
class LoginInfo extends ChangeNotifier {
  /// The username of login.
  String get userName => _userName;
  String _userName = '';

  /// Whether a user has logged in.
  bool get loggedIn => _userName.isNotEmpty;

  /// Logs in a user.
  void login(String userName) {
    _userName = userName;
    notifyListeners();
  }

  /// Logs out the current user.
  void logout() {
    _userName = '';
    notifyListeners();
  }
}

/// The login information.
class LoginInfo2 extends ChangeNotifier {
  /// The username of login.
  String get userName => _userName;
  String _userName = '';

  /// Whether a user has logged in.
  bool get loggedIn => _userName.isNotEmpty;

  /// Logs in a user.
  Future<void> login(String userName) async {
    _userName = userName;
    notifyListeners();
    await Future<void>.delayed(const Duration(microseconds: 2500));
  }

  /// Logs out the current user.
  Future<void> logout() async {
    _userName = '';
    notifyListeners();
    await Future<void>.delayed(const Duration(microseconds: 2500));
  }
}

/// The relation of a person in a family.
class FamilyPerson {
  /// Creates a [FamilyPerson].
  FamilyPerson({required this.family, required this.person});

  /// The family.
  final Family family;

  /// the person.
  final Person person;
}

/// The repository.
class Repository {
  /// A random number generator.
  static final Random rnd = Random();

  /// Gets the families data.
  Future<List<Family>> getFamilies() async {
    // simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));

    // simulate error
    // if (rnd.nextBool()) throw Exception('error fetching families');

    // return data "fetched over the network"
    return Families.data;
  }

  /// Gets a family from the repository.
  Future<Family> getFamily(String fid) async =>
      (await getFamilies()).family(fid);

  /// Gets a person from the repository.
  Future<FamilyPerson> getPerson(String fid, String pid) async {
    final Family family = await getFamily(fid);
    return FamilyPerson(family: family, person: family.person(pid));
  }
}

/// The repository.
class Repository2 {
  Repository2._(this.userName);

  /// The username.
  final String userName;

  /// Gets a repository with the username.
  static Future<Repository2> get(String userName) async {
    // simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));
    return Repository2._(userName);
  }

  /// A random number generator.
  static final Random rnd = Random();

  /// Gets the families data.
  Future<List<Family>> getFamilies() async {
    // simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));

    // simulate error
    // if (rnd.nextBool()) throw Exception('error fetching families');

    // return data "fetched over the network"
    return Families.data;
  }

  /// Gets a family from the repository.
  Future<Family> getFamily(String fid) async =>
      (await getFamilies()).family(fid);

  /// Gets a person from the repository.
  Future<FamilyPerson> getPerson(String fid, String pid) async {
    final Family family = await getFamily(fid);
    return FamilyPerson(family: family, person: family.person(pid));
  }
}

/// A state stream.
abstract class StateStream<T> {
  /// Creates a [StateStream].
  StateStream();

  /// Creates a [StateStream] with an initial value.
  StateStream.seeded(T value) : state = value {
    _controller.add(value);
  }

  final StreamController<T> _controller = StreamController<T>();

  /// The state.
  late T state;

  /// The [Stream] object.
  Stream<T> get stream => _controller.stream;

  /// Pipes a new state into the stream.
  void emit(T state) {
    this.state = state;
    _controller.add(state);
  }

  /// Disposes the stream.
  void dispose() {
    _controller.close();
  }
}

/// Stream for whether the user is currently logged in.
class LoggedInState extends StateStream<bool> {
  /// Creates a [LoggedInState].
  LoggedInState();

  /// Creates a [LoggedInState] with an initial value.
  LoggedInState.seeded(bool value) : super.seeded(value);
}
