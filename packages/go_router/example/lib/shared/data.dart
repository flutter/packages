import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class Person {
  Person({required this.id, required this.name, required this.age});

  final String id;
  final String name;
  final int age;
}

class Family {
  Family({required this.id, required this.name, required this.people});

  final String id;
  final String name;
  final List<Person> people;

  Person person(String pid) => people.singleWhere(
        (p) => p.id == pid,
        orElse: () => throw Exception('unknown person $pid for family $id'),
      );
}

class Families {
  static final data = [
    Family(
      id: 'f1',
      name: 'Sells',
      people: [
        Person(id: 'p1', name: 'Chris', age: 52),
        Person(id: 'p2', name: 'John', age: 27),
        Person(id: 'p3', name: 'Tom', age: 26),
      ],
    ),
    Family(
      id: 'f2',
      name: 'Addams',
      people: [
        Person(id: 'p1', name: 'Gomez', age: 55),
        Person(id: 'p2', name: 'Morticia', age: 50),
        Person(id: 'p3', name: 'Pugsley', age: 10),
        Person(id: 'p4', name: 'Wednesday', age: 17),
      ],
    ),
    Family(
      id: 'f3',
      name: 'Hunting',
      people: [
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

  static Family family(String fid) => data.family(fid);
}

extension on List<Family> {
  Family family(String fid) => singleWhere(
        (f) => f.id == fid,
        orElse: () => throw Exception('unknown family $fid'),
      );
}

class LoginInfo extends ChangeNotifier {
  var _userName = '';
  String get userName => _userName;
  bool get loggedIn => _userName.isNotEmpty;

  void login(String userName) {
    _userName = userName;
    notifyListeners();
  }

  void logout() {
    _userName = '';
    notifyListeners();
  }
}

class LoginInfo2 extends ChangeNotifier {
  var _userName = '';
  String get userName => _userName;
  bool get loggedIn => _userName.isNotEmpty;

  Future<void> login(String userName) async {
    _userName = userName;
    notifyListeners();
    await Future<void>.delayed(const Duration(microseconds: 2500));
  }

  Future<void> logout() async {
    _userName = '';
    notifyListeners();
    await Future<void>.delayed(const Duration(microseconds: 2500));
  }
}

class FamilyPerson {
  FamilyPerson({required this.family, required this.person});

  final Family family;
  final Person person;
}

class Repository {
  static final rnd = Random();

  Future<List<Family>> getFamilies() async {
    // simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));

    // simulate error
    // if (rnd.nextBool()) throw Exception('error fetching families');

    // return data "fetched over the network"
    return Families.data;
  }

  Future<Family> getFamily(String fid) async =>
      (await getFamilies()).family(fid);

  Future<FamilyPerson> getPerson(String fid, String pid) async {
    final family = await getFamily(fid);
    return FamilyPerson(family: family, person: family.person(pid));
  }
}

class Repository2 {
  Repository2._(this.userName);
  final String userName;

  static Future<Repository2> get(String userName) async {
    // simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));
    return Repository2._(userName);
  }

  static final rnd = Random();

  Future<List<Family>> getFamilies() async {
    // simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));

    // simulate error
    // if (rnd.nextBool()) throw Exception('error fetching families');

    // return data "fetched over the network"
    return Families.data;
  }

  Future<Family> getFamily(String fid) async =>
      (await getFamilies()).family(fid);

  Future<FamilyPerson> getPerson(String fid, String pid) async {
    final family = await getFamily(fid);
    return FamilyPerson(family: family, person: family.person(pid));
  }
}

abstract class StateStream<T> {
  StateStream();

  StateStream.seeded(T value) : state = value {
    _controller.add(value);
  }

  final StreamController<T> _controller = StreamController<T>();
  late T state;

  Stream<T> get stream => _controller.stream;

  void emit(T state) {
    this.state = state;
    _controller.add(state);
  }

  void dispose() {
    _controller.close();
  }
}

class LoggedInState extends StateStream<bool> {
  LoggedInState();

  // ignore: avoid_positional_boolean_parameters
  LoggedInState.seeded(bool value) : super.seeded(value);
}
