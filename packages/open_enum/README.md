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

## Usage

### 1. Defining an Open Enum (String-based)

To define an open enum, create an extension type wrapping a `String` (or any other type) and implement `OpenEnum<T>`:

<?code-excerpt "readme_excerpts.dart (Definition)"?>
```dart
extension type const UserRole(String name) implements OpenEnum<String> {
  static const UserRole admin = UserRole('admin');
  static const UserRole member = UserRole('member');

  // We can add this in a minor update without breaking any consumer switches!
  static const UserRole guest = UserRole('guest');

  // Provide a list of known values, just like standard enums.
  static const List<UserRole> values = [admin, member, guest];
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
>
> <?code-excerpt "readme_excerpts.dart (SwitchExpression)"?>
> ```dart
> String getLabel(UserRole role) => switch (role) {
>       UserRole.admin => 'Administrator',
>       UserRole.member => 'Member',
>       _ => 'Other', // Required by compiler, safe against future additions
>     };
> ```

---

## Helper Utilities

The `open_enum` library provides convenient extensions on `Iterable` collections of open enums to mirror the standard Dart enum developer experience.

### Looking up by Representation Value

Use `.byValue()` to look up an element by its underlying representation value (e.g., `String` or `int`):

<?code-excerpt "readme_excerpts.dart (ByValue)"?>
```dart
final UserRole? role = UserRole.values.byValue('admin'); // Returns UserRole.admin
final UserRole? invalid = UserRole.values.byValue('super-user'); // Returns null
```

### Looking up by String Name

For string-represented enums, we provide `.byName()` and `.byNameOrNull()` to perfectly match the standard Dart `enum` API:

<?code-excerpt "readme_excerpts.dart (ByName)"?>
```dart
// Throws ArgumentError if the name is not found, matching standard enum behavior
final UserRole roleByName = UserRole.values.byName('admin');

// Returns null if the name is not found (safer alternative)
final UserRole? safeRole = UserRole.values.byNameOrNull('super-user');
```
