# open_enum
<?code-excerpt path-base="example/lib"?>

A lightweight, pure-Dart library for defining **open (non-exhaustive) enums** using Dart 3.3+ extension types. This prevents breaking API changes when adding new values to an enum in minor or patch releases of a package.

## The Problem

In Dart 3, standard `enum`s are strictly exhaustive. If a package consumer writes a `switch` statement or expression over a standard enum, adding a new value to that enum in a future package update is a **source-breaking change** for the consumer because their `switch` is no longer exhaustive.

This makes evolving public APIs in package ecosystems incredibly difficult.

## The Solution: Open Enums

`open_enum` utilizes Dart 3.3's zero-cost **Extension Types** to implement open enums. By wrapping a primitive type (like `String` or `int`), you get:
- **No breaking changes:** You can add new values to your open enums in minor updates without breaking consumer code.
- **Zero runtime cost:** Extension types are completely erased at runtime; they compile down to the underlying representation (e.g., a plain `String` or `int`), meaning no extra object allocations.
- **Strict type safety:** Consumers cannot pass arbitrary strings or integers where your enum type is expected.
- **Exhaustiveness opt-out:** The compiler will not warn or fail on `switch` statements, but will still require a wildcard/fallback (`_`) for `switch` expressions (keeping them safe).

---

## Getting Started

Add `open_enum` to your `pubspec.yaml`:

```yaml
dependencies:
  open_enum: ^0.1.0
```

---

## Basic Usage

### 1. Defining an Open Enum (String-based)

To define an open enum, create an extension type wrapping a `String` (or any other type) and implement `OpenEnum<T>`. 

> [!TIP]
> Use a private constructor (`UserRole._`) to prevent consumers outside your package from constructing arbitrary new instances of your enum. This keeps the enum set strictly closed to your declared constants.

<?code-excerpt "readme_excerpts.dart (Definition)"?>
```dart
extension type const UserRole._(String name) implements OpenEnum<String> {
  static const UserRole admin = UserRole._('admin');
  static const UserRole member = UserRole._('member');

  // We can add this in a minor update without breaking any consumer switches!
  static const UserRole guest = UserRole._('guest');

  // Provide a list of known values, just like standard enums.
  static const List<UserRole> values = [admin, member, guest];

  /// Returns the index of this value in [values] list, matching standard enum `.index`.
  int get index => values.indexOf(this);

  /// Custom string representation (since extension types cannot override `toString()`).
  String get label => 'UserRole.$name';
}
```

### 2. Switching on Open Enums

Consumers can switch on your open enum without being forced to write exhaustive matches for all cases in statement switches. If they encounter a value they don't handle, it will safely fall through.

<?code-excerpt "readme_excerpts.dart (SwitchStatement)"?>
```dart
void handleRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      print('Access granted.');
    case UserRole.member:
      print('Standard access.');
    // Any unhandled values (like a newly added 'guest') will safely fall through!
  }
}

```

> [!NOTE]
> If a consumer uses a **switch expression**, Dart always requires a default/wildcard case (`_`) because expressions must always evaluate to a value. This naturally protects them from new additions:

<?code-excerpt "readme_excerpts.dart (SwitchExpression)"?>
```dart
String getLabel(UserRole role) => switch (role) {
  UserRole.admin => 'Administrator',
  UserRole.member => 'Member',
  _ => 'Other', // Required by compiler, safe against future additions
};
```

### 3. Lookup Utilities & Deserialization

The `open_enum` library provides convenient extensions on `Iterable` collections of open enums to handle parsing and deserialization:

#### Looking up by Representation Value
Use `.byValue()` to look up an element by its underlying representation value:

<?code-excerpt "readme_excerpts.dart (ByValue)"?>
```dart
final UserRole? role = UserRole.values.byValue('admin'); // Returns UserRole.admin
final UserRole? invalid = UserRole.values.byValue('super-user'); // Returns null
```

#### Looking up by String Name
For string-represented enums, `.byName()` and `.byNameOrNull()` perfectly match standard Dart `enum` behavior:

<?code-excerpt "readme_excerpts.dart (ByName)"?>
```dart
// Throws ArgumentError if the name is not found, matching standard enum behavior
final UserRole roleByName = UserRole.values.byName('admin');

// Returns null if the name is not found (safer alternative)
final UserRole? safeRole = UserRole.values.byNameOrNull('super-user');
```

---

## Advanced Patterns

### 1. Open Enums with both Index and Name (`OpenEnumRecord`)

If you want your open enum to natively support both integer `index` and string `name` properties without writing any manual lookup boilerplate, implement `OpenEnumRecord` by wrapping a named record `({int index, String name})`:

<?code-excerpt "readme_excerpts.dart (DefinitionRecord)"?>
```dart
extension type const UserRoleRecord._(({int index, String name}) data) implements OpenEnumRecord {
  static const UserRoleRecord admin = UserRoleRecord._((index: 0, name: 'admin'));
  static const UserRoleRecord member = UserRoleRecord._((index: 1, name: 'member'));
  static const UserRoleRecord guest = UserRoleRecord._((index: 2, name: 'guest'));

  static const List<UserRoleRecord> values = [admin, member, guest];
}
```

By using `OpenEnumRecord`, you automatically get:
- `.index` and `.name` properties natively on every instance.
- `.byIndex(int index)` lookup on collections.
- `.byName(String name)` and `.byNameOrNull(String name)` lookup on collections.

> [!IMPORTANT]
> Because Record types are completely erased at runtime, standard tools like `jsonEncode` cannot reflect on them to find custom methods. To serialize an `OpenEnumRecord`, you must call `.toJson()` explicitly:
> ```dart
> final json = jsonEncode(role.toJson()); // Produces {"index":0,"name":"admin"}
> ```

### 2. Type-Safe Bitmask / Flag Enums

Standard Dart enums cannot be combined using bitwise operations (`|`, `&`). With `open_enum`, you can define type-safe flags wrapping an `int` representation that compile down to zero-cost integers at runtime:

<?code-excerpt "readme_excerpts.dart (Bitmask)"?>
```dart
extension type const Permission._(int value) implements OpenEnum<int> {
  static const Permission read = Permission._(1 << 0);
  static const Permission write = Permission._(1 << 1);
  static const Permission execute = Permission._(1 << 2);

  Permission operator |(Permission other) => Permission._(value | other.value);
  Permission operator &(Permission other) => Permission._(value & other.value);
  bool has(Permission other) => (value & other.value) == other.value;
}
```

This lets consumers combine and check flags cleanly:

<?code-excerpt "readme_excerpts.dart (BitmaskUsage)"?>
```dart
void bitmaskUsage() {
  final Permission rw = Permission.read | Permission.write;
  print(rw.has(Permission.read)); // true
  print(rw.has(Permission.execute)); // false
}
```

---

## Benefits & Trade-offs (Drawbacks)

### Benefits
* **API Evolution Safety:** You can add new options to your enum at any time in a minor update. Existing consumers' `switch` statements will continue compiling and running without breaking.
* **Zero Runtime Cost:** Because they are built on Dart extension types, these types compile down to their representation (e.g. `String` or `int`) at runtime, preventing heap object allocation overhead.
* **Native JSON Serialization:** They natively serialize to JSON out-of-the-box using standard tools like `jsonEncode` (since they resolve to their wrapped primitives at runtime).
* **Closed-Set Guarantees:** By using private constructors (`MyEnum._`), you prevent consumers from creating arbitrary invalid instances of your enum.

### Trade-offs & Drawbacks
* **Opt-Out of Exhaustiveness Warnings:** Because enums are open, the compiler *cannot* warn you if you forget to handle a new enum case in a `switch` statement. If you *want* compile-time errors when cases are added, you should use standard Dart `enum`s.
* **Manual `values` Bookkeeping:** Dart cannot reflect on classes or extension types at AOT runtime. You must manually define and maintain the `static const List<T> values` list.
* **Custom `toString()` Limitations:** Extension types cannot override `Object.toString()`. Calling `toString()` at runtime returns the wrapped primitive (e.g., `'admin'`). To print detailed types (like `'UserRole.admin'`), you must define a custom getter like `label`.
