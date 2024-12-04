// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

// This file must not import `dart:ui`, directly or indirectly, as it is
// intended to function even in pure Dart server or CLI environments.

import 'model.dart';

/// Parse a Remote Flutter Widgets text data file.
///
/// This data is usually used in conjunction with [DynamicContent].
///
/// Parsing this format is about ten times slower than parsing the binary
/// variant; see [decodeDataBlob]. As such it is strongly discouraged,
/// especially in resource-constrained contexts like mobile applications.
///
/// ## Format
///
/// This format is inspired by JSON, but with the following changes:
///
///  * end-of-line comments are supported, using the "//" syntax from C (and
///    Dart).
///
///  * block comments are supported, using the "/*...*/" syntax from C (and
///    Dart).
///
///  * map keys may be unquoted when they are alphanumeric.
///
///  * "null" is not a valid value except as a value in maps, where it is
///    equivalent to omitting the corresponding key entirely. This is allowed
///    primarily as a development aid to explicitly indicate missing keys. (The
///    data model itself, and the binary format (see [decodeDataBlob]), do not
///    contain this feature.)
///
///  * integers and doubles are distinguished explicitly, via the presence of
///    the decimal point and/or exponent characters. Integers may also be
///    expressed as hex literals. Numbers are explicitly 64 bit precision;
///    specifically, signed 64 bit integers, or binary64 floating point numbers.
///
///  * files are always rooted at a map. (Different versions of JSON are
///    ambiguous or contradictory about this.)
///
/// Here is the BNF:
///
/// ```bnf
/// root ::= WS* map WS*
/// ```
///
/// Every Remote Flutter Widget text data file must match the `root` production.
///
/// ```bnf
/// map ::= "{" ( WS* entry WS* "," )* WS* entry? WS* "}"
/// entry ::= ( identifier | string ) WS* ":" WS* ( value | "null" )
/// ```
///
/// Maps are comma-separated lists of name-value pairs (a single trailing comma
/// is permitted), surrounded by braces. The key must be either a quoted string
/// or an unquoted identifier. The value must be either the keyword "null",
/// which is equivalent to the entry being omitted, or a value as defined below.
/// Duplicates (notwithstanding entries that use the keyword "null") are not
/// permitted. In general the use of the "null" keyword is discouraged and is
/// supported only to allow mechanically-generated data to consistently include
/// every key even when one has no value.
///
/// ```bnf
/// value ::= map | list | integer | double | string | "true" | "false"
/// ```
///
/// The "true" and "false" keywords represented the boolean true and false
/// values respectively.
///
/// ```bnf
/// list ::= "[" ( WS* value WS* "," )* WS* value? WS* "]"
/// ```
///
/// Following the pattern set by maps, lists are comma-separated lists of values
/// (a single trailing comma is permitted), surrounded by brackets.
///
/// ```bnf
/// identifier ::= letter ( letter | digit )*
/// letter ::= <a character in the ranges A-Z, a-z, or the underscore>
/// digit ::= <a character in the range 0-9>
/// ```
///
/// Identifiers are alphanumeric sequences (with the underscore considered a
/// letter) that do not start with a digit.
///
/// ```bnf
/// string ::= DQ stringbodyDQ* DQ | SQ stringbodySQ* SQ
/// DQ ::= <U+0022>
/// stringbodyDQ ::= escape | characterDQ
/// characterDQ ::= <U+0000..U+10FFFF except U+000A, U+0022, U+005C>
/// SQ ::= <U+0027>
/// stringbodySQ ::= escape | characterSQ
/// characterSQ ::= <U+0000..U+10FFFF except U+000A, U+0027, U+005C>
/// escape ::= <U+005C> ("b" | "f" | "n" | "r" | "t" | symbol | unicode)
/// symbol ::= <U+0022, U+0027, U+005C, or U+002F>
/// unicode ::= "u" hex hex hex hex
/// hex ::= <a character in the ranges A-F, a-f, or 0-9>
/// ```
///
/// Strings are double-quoted (U+0022, ") or single-quoted (U+0027, ') sequences
/// of zero or more Unicode characters that do not include a newline, the quote
/// character used, or the backslash character, mixed with zero or more escapes.
///
/// Escapes are a backslash character followed by another character, as follows:
///
///  * `\b`: represents U+0008
///  * `\f`: represents U+000C
///  * `\n`: represents U+000A
///  * `\r`: represents U+000D
///  * `\t`: represents U+0009
///  * `"`: represents U+0022 (")
///  * `'`: represents U+0027 (')
///  * `/`: represents U+002F (/)
///  * `\`: represents U+005C (\)
///  * `\uXXXX`: represents the UTF-16 codepoint with code XXXX.
///
/// Characters outside the basic multilingual plane must be represented either
/// as literal characters, or as two escapes identifying UTF-16 surrogate pairs.
/// (This is for compatibility with JSON.)
///
/// ```bnf
/// integer ::= "-"? decimal | hexadecimal
/// decimal ::= digit+
/// hexadecimal ::= ("0x" | "0X") hex+
/// ```
///
/// The "digit" (0-9) and "hex" (0-9, A-F, a-f) terminals are described earlier.
///
/// In the "decimal" form, the digits represent their value in base ten. A
/// leading hyphen indicates the number is negative. In the "hexadecimal" form,
/// the number is always positive, and is represented by the hex digits
/// interpreted in base sixteen.
///
/// The numbers represented must be in the range -9,223,372,036,854,775,808 to
/// 9,223,372,036,854,775,807.
///
/// ```bnf
/// double ::= "-"? digit+ ("." digit+)? (("e" | "E") "-"? digit+)?
/// ```
///
/// Floating point numbers are represented by an optional negative sign
/// indicating the number is negative, a significand with optional fractional
/// component in the form of digits in base ten giving the integer component
/// followed optionally by a decimal point and further base ten digits giving
/// the fractional component, and an exponent which itself is represented by an
/// optional negative sign indicating a negative exponent and a sequence of
/// digits giving the base ten exponent itself.
///
/// The numbers represented must be values that can be expressed in the IEEE754
/// binary64 format.
///
/// ```bnf
/// WS ::= ( <U+0020> | <U+000A> | "//" comment* <U+000A or EOF> | "/*" blockcomment "*/" )
/// comment ::= <U+0000..U+10FFFF except U+000A>
/// blockcomment ::= <any number of U+0000..U+10FFFF characters not containing the sequence U+002A U+002F>
/// ```
///
/// The `WS` token is used to represent where whitespace and comments are
/// allowed.
///
/// See also:
///
///  * [parseLibraryFile], which uses a superset of this format to decode
///    Remote Flutter Widgets text library files.
///  * [decodeDataBlob], which decodes the binary variant of this format.
DynamicMap parseDataFile(String file) {
  final _Parser parser = _Parser(_tokenize(file), null);
  return parser.readDataFile();
}

/// Parses a Remote Flutter Widgets text library file.
///
/// Remote widget libraries are usually used in conjunction with a [Runtime].
///
/// Parsing this format is about ten times slower than parsing the binary
/// variant; see [decodeLibraryBlob]. As such it is strongly discouraged,
/// especially in resource-constrained contexts like mobile applications.
///
/// ## Format
///
/// The format is a superset of the format defined by [parseDataFile].
///
/// Remote Flutter Widgets text library files consist of a list of imports
/// followed by a list of widget declarations.
///
/// ### Imports
///
/// A remote widget library file is identified by a name which consists of
/// several parts, which are by convention expressed separated by periods; for
/// example, `core.widgets` or `net.example.x`.
///
/// A library's name is specified when the library is provided to the runtime
/// using [Runtime.update].
///
/// A remote widget library depends on one or more other libraries that define
/// the widgets that the primary library depends on. These dependencies can
/// themselves be remote widget libraries, for example describing commonly-used
/// widgets like branded buttons, or "local widget libraries" which are declared
/// and hard-coded in the client itself and that provide a way to reference
/// actual Flutter widgets (see [LocalWidgetLibrary]).
///
/// The Remote Flutter Widgets package ships with two local widget libraries,
/// usually given the names `core.widgets` (see [createCoreWidgets]) and
/// `core.material` (see [createMaterialWidgets]). An application can declare
/// other local widget libraries for use by their remote widgets. These could
/// correspond to UI controls, e.g. branded widgets used by other parts of the
/// application, or to complete experiences, e.g. core parts of the application.
/// For example, a blogging application might use Remote Flutter Widgets to
/// represent the CRM parts of the experience, with the rich text editor being
/// implemented on the client as a custom widget exposed to the remote libraries
/// as a widget in a local widget library.
///
/// A library lists the other libraries that it depends on by name. When a
/// widget is referenced, it is looked up by name first by examining the widget
/// declarations in the file itself, then by examining the declarations of each
/// dependency in turn, in a depth-first search.
///
/// It is an error for there to be a loop in the imports.
///
/// Imports have this form:
///
/// ```none
/// import library.name;
/// ```
///
/// For example:
///
/// ```none
/// import core.widgets;
/// ```
///
/// ### Widget declarations
///
/// The primary purpose of a remote widget library is to provide widget
/// declarations. Each declaration defines a new widget. Widgets are defined in
/// terms of other widgets, like stateless and stateful widgets in Flutter
/// itself. As such, a widget declaration consists of a widget constructor call.
///
/// The widget declarations come after the imports.
///
/// To declare a widget named A in terms of a widget B, the following form is used:
///
/// ```none
/// widget A = B();
/// ```
///
/// This declares a widget A, whose implementation is simply to use widget B.
///
/// If the widget A is to be stateful, a map is inserted before the equals sign:
///
/// ```none
/// widget A { } = B();
/// ```
///
/// The map describes the default values of the state. For example, a button
/// might have a "down" state, which is initially false:
///
/// ```none
/// widget Button { down: false } = Container();
/// ```
///
/// _See the section on State below._
///
/// ### Widget constructor calls
///
/// A widget constructor call is an invocation of a remote or local widget
/// declaration, along with its arguments. Arguments are a map of key-value
/// pairs, where the values can be any of the types in the data model defined
/// above plus any of the types defined below in this section, such as
/// references to arguments, the data model, widget builders, loops, state,
/// switches or event handlers.
///
/// In this example, several constructor calls are nested together:
///
/// ```none
/// widget Foo = Column(
///   children: [
///     Container(
///       child: Text(text: "Hello"),
///     ),
///     Builder(
///       builder: (scope) => Text(text: scope.world),
///     ),
///   ],
/// );
/// ```
///
/// The `Foo` widget is defined to create a `Column` widget. The `Column(...)`
/// is a constructor call with one argument, named `children`, whose value is a
/// list which itself contains a single constructor call, to `Container`. That
/// constructor call also has only one argument, `child`, whose value, again, is
/// a constructor call, in this case creating a `Text` widget.
///
/// ### Widget Builders
///
/// Widget builders take a single argument and return a widget.
/// The [DynamicMap] argument consists of key-value pairs where values
/// can be of any types in the data model. Widget builders arguments are lexically
/// scoped so a given constructor call has access to any arguments where it is
/// defined plus arguments defined by its parents (if any).
///
/// In this example several widget builders are nested together:
///
/// ```none
/// widget Foo {text: 'this is cool'} = Builder(
///   builder: (foo) => Builder(
///     builder: (bar) => Builder(
///       builder: (baz) => Text(
///         text: [
///           args.text,
///           state.text,
///           data.text,
///           foo.text,
///           bar.text,
///           baz.text,
///         ],
///       ),
///     ),
///   ),
/// );
/// ```
///
/// ### References
///
/// Remote widget libraries typically contain _references_, e.g. to the
/// arguments of a widget, or to the [DynamicContent] data, or to a stateful
/// widget's state.
///
/// The various kinds of references all have the same basic pattern, a prefix
/// followed by period-separated identifiers, strings, or integers. Identifiers
/// and strings are used to index into maps, while integers are used to index
/// into lists.
///
/// For example, "foo.2.fruit" would reference the key with the value "Kiwi" in
/// the following structure:
///
/// ```c
/// {
///   foo: [
///     { fruit: "Apple" },
///     { fruit: "Banana" },
///     { fruit: "Kiwi" }, // foo.2.fruit is the string "Kiwi" here
///   ],
///   bar: [ ],
/// }
/// ```
///
/// Peferences to a widget's arguments use "args" as the first component:
///
/// <code>args<i>.foo.bar</i></code>
///
/// References to the data model use use "data" as the first component, and
/// references to state use "state" as the first component:
///
/// <code>data<i>.foo.bar</i></code>
///
/// <code>state<i>.foo.bar</i></code>
///
/// Finally, references to loop variables use the identifier specified in the
/// loop as the first component:
///
/// <code><i>ident.foo.bar</i></code>
///
/// #### Argument references
///
/// Instead of passing literal values as arguments in widget constructor calls,
/// a reference to one of the arguments of the remote widget being defined
/// itself can be provided instead.
///
/// For example, suppose one instantiated a widget Foo as follows:
///
/// ```none
/// Foo(name: "Bobbins")
/// ```
///
/// ...then in the definition of Foo, one might pass the value of this "name"
/// argument to another widget, say a Text widget, as follows:
///
/// ```none
/// widget Foo = Text(text: args.name);
/// ```
///
/// The arguments can have structure. For example, if the argument passed to Foo
/// was:
///
/// ```none
/// Foo(show: { name: "Cracking the Cryptic", phrase: "Bobbins" })
/// ```
///
/// ...then to specify the leaf node whose value is the string "Bobbins", one
/// would specify an argument reference consisting of the values "show" and
/// "phrase", as in `args.show.phrase`. For example:
///
/// ```none
/// widget Foo = Text(text: args.show.phrase);
/// ```
///
/// #### Data model references
///
/// Instead of passing literal values as arguments in widget constructor calls,
/// or references to one's own arguments, a reference to one of the nodes in the
/// data model can be provided instead.
///
/// The data model is a tree of maps and lists with leaves formed of integers,
/// doubles, bools, and strings (see [DynamicContent]). For example, if the data
/// model looks like this:
///
/// ```none
/// { server: { cart: [ { name: "Apple"}, { name: "Banana"} ] }
/// ```
///
/// ...then to specify the leaf node whose value is the string "Banana", one
/// would specify a data model reference consisting of the values "server",
/// "cart", 1, and "name", as in `data.server.cart.1.name`. For example:
///
/// ```none
/// Text(text: data.server.cart.1.name)
/// ```
///
/// ### Loops
///
/// In a list, a loop can be employed to map another list into the host list,
/// mapping values of the embedded list according to a provided template. Within
/// the template, references to the value from the embedded list being expanded
/// can be provided using a loop reference, which is similar to argument and
/// data references.
///
/// A widget that shows all the values from a list in a [ListView] might look
/// like this:
///
/// ```none
/// widget Items = ListView(
///   children: [
///     ...for item in args.list:
///       Text(text: item),
///   ],
/// );
/// ```
///
/// Such a widget would be used like this:
///
/// ```none
/// Items(list: [ "Hello", "World" ])
/// ```
///
/// The syntax for a loop uses the following form:
///
/// <code>...for <i>ident</i> in <i>list</i>: <i>template</i></code>
///
/// ...where _ident_ is the identifier to bind to each value in the list, _list_
/// is some value that evaluates to a list, and _template_ is a value that is to
/// be evaluated for each item in _list_.
///
/// This loop syntax is only valid inside lists.
///
/// Loop references use the _ident_. In the example above, that is `item`. In
/// more elaborate examples, it can include subreferences. For example:
///
/// ```none
/// widget Items = ListView(
///   children: [
///     Text(text: 'Products:'),
///     ...for item in args.products:
///       Text(text: product.name.displayName),
///     Text(text: 'End of list.'),
///   ],
/// );
/// ```
///
/// This might be used as follows:
///
/// ```none
/// Items(products: [
///   { name: { abbreviation: "TI4", displayName: "Twilight Imperium IV" }, price: 120.0 },
///   { name: { abbreviation: "POK", displayName: "Prophecy of Kings" }, price: 100.0 },
/// ])
/// ```
///
/// ### State
///
/// A widget declaration can say that it has an "initial state", the structure
/// of which is the same as the data model structure (maps and lists of
/// primitive types, the root is a map).
///
/// Here a button is described as having a "down" state whose first value is
/// "false":
///
/// ```none
/// widget Button { down: false } = Container(
///   // ...
/// );
/// ```
///
/// If a widget has state, then it can be referenced in the same way as the
/// widget's arguments and the data model can be referenced, and it can be
/// changed using event handlers as described below.
///
/// Here, the button's state is referenced (in a pretty nonsensical way;
/// controlling whether its label wraps based on the value of the state):
///
/// ```none
/// widget Button { down: false } = Container(
///   child: Text(text: 'Hello World', softWrap: state.down),
/// );
/// ```
///
/// State is usually used with Switches and state-setting handlers.
///
/// ### Switches
///
/// Anywhere in a widget declaration, a switch can be employed to change the
/// evaluated value used at runtime. A switch has a value that is being used to
/// control the switch, and then a series of cases with values to use if the
/// control value matches the case value. A default can be provided.
///
/// The control value is usually a reference to arguments, data, state, or a
/// loop variable.
///
/// The syntax for a switch uses the following form:
///
/// ```none
/// switch value {
///   case1: template1,
///   case2: template2,
///   case3: template3,
///   // ...
///   default: templateD,
/// }
/// ```
///
/// ...where _value_ is the control value that will be compared to each case,
/// the _caseX_ values are the values to which the control value is compared,
/// _templateX_ are the templates to use, and _templateD_ is the default
/// template to use if none of the cases can be met. Any number of cases can be
/// specified; the template of the first one that exactly matches the given
/// control value is the one that is used. The default entry is optional. If no
/// value matches and there is no default, the switch evaluates to the "missing"
/// value (null).
///
/// Extending the earlier button, this would move the margin around so that it
/// appeared pressed when the "down" state was true (but note that we still
/// don't have anything to toggle that state!):
///
/// ```none
/// widget Button { down: false } = Container(
///   margin: switch state.down {
///     false: [ 0.0, 0.0, 8.0, 8.0 ],
///     true: [ 8.0, 8.0, 0.0, 0.0 ],
///   },
///   decoration: { type: "box", border: [ {} ] },
///   child: args.child,
/// );
/// ```
///
/// ### Event handlers
///
/// There are two kinds of event handlers: those that signal an event for the
/// host to handle (potentially by forwarding it to a server), and those that
/// change the widget's state.
///
/// Signalling event handlers have a name and an arguments map:
///
/// ```none
/// event "..." { }
/// ```
///
/// The string is the name of the event, and the arguments map is the data to
/// send with the event.
///
/// For example, the event handler in the following sequence sends the event
/// called "hello" with a map containing just one key, "id", whose value is 1:
///
/// ```none
/// Button(
///   onPressed: event "hello" { id: 1 },
///   child: Text(text: "Greetings"),
/// );
/// ```
///
/// Event handlers that set state have a reference to a state, and a new value
/// to assign to that state. Such handlers are only meaningful within widgets
/// that have state, as described above. They have this form:
///
/// ```none
/// set state.foo.bar = value
/// ```
///
/// The `state.foo.bar` part is a state reference (which must identify a part of
/// the state that exists), and `value` is the new value to assign to that state.
///
/// This lets us finish the earlier button:
///
/// ```none
/// widget Button { down: false } = GestureDetector(
///   onTapDown: set state.down = true,
///   onTapUp: set state.down = false,
///   onTapCancel: set state.down = false,
///   onTap: args.onPressed,
///   child: Container(
///     margin: switch state.down {
///       false: [ 0.0, 0.0, 8.0, 8.0 ],
///       true: [ 8.0, 8.0, 0.0, 0.0 ],
///     },
///     decoration: { type: "box", border: [ {} ] },
///     child: args.child,
///   ),
/// );
/// ```
///
/// ## Source identifier
///
/// The optional `sourceIdentifier` parameter can be provided to cause the
/// parser to track source locations for [BlobNode] subclasses included in the
/// parsed subtree. If the value is null (the default), then source locations
/// are not tracked. If the value is non-null, it is used as the value of the
/// [SourceLocation.source] for each [SourceRange] of each [BlobNode.source].
///
/// See also:
///
///  * [encodeLibraryBlob], which encodes the output of this method
///    into the binary variant of this format.
///  * [parseDataFile], which uses a subset of this format to decode
///    Remote Flutter Widgets text data files.
///  * [decodeLibraryBlob], which decodes the binary variant of this format.
RemoteWidgetLibrary parseLibraryFile(String file, { Object? sourceIdentifier }) {
  final _Parser parser = _Parser(_tokenize(file), sourceIdentifier);
  return parser.readLibraryFile();
}

const Set<String> _reservedWords = <String>{
  'args',
  'data',
  'event',
  'false',
  'set',
  'state',
  'true',
};

void _checkIsNotReservedWord(String identifier, _Token identifierToken) {
  if (_reservedWords.contains(identifier)) {
    throw ParserException._fromToken('$identifier is a reserved word', identifierToken);
  }
}

sealed class _Token {
  _Token(this.line, this.column, this.start, this.end);
  final int line;
  final int column;
  final int start;
  final int end;
}

class _SymbolToken extends _Token {
  _SymbolToken(this.symbol, int line, int column, int start, int end): super(line, column, start, end);
  final int symbol;

  static const int dot = 0x2E;
  static const int tripleDot = 0x2026;
  static const int openParen = 0x28; // U+0028 LEFT PARENTHESIS character (()
  static const int closeParen = 0x29; // U+0029 RIGHT PARENTHESIS character ())
  static const int comma = 0x2C; // U+002C COMMA character (,)
  static const int colon = 0x3A; // U+003A COLON character (:)
  static const int semicolon = 0x3B; // U+003B SEMICOLON character (;)
  static const int equals = 0x3D; // U+003D EQUALS SIGN character (=)
  static const int greatherThan = 0x3E; // U+003D GREATHER THAN character (>)
  static const int openBracket = 0x5B; // U+005B LEFT SQUARE BRACKET character ([)
  static const int closeBracket = 0x5D; // U+005D RIGHT SQUARE BRACKET character (])
  static const int openBrace = 0x7B; // U+007B LEFT CURLY BRACKET character ({)
  static const int closeBrace = 0x7D; // U+007D RIGHT CURLY BRACKET character (})

  @override
  String toString() => String.fromCharCode(symbol);
}

class _IntegerToken extends _Token {
  _IntegerToken(this.value, int line, int column, int start, int end): super(line, column, start, end);
  final int value;

  @override
  String toString() => '$value';
}

class _DoubleToken extends _Token {
  _DoubleToken(this.value, int line, int column, int start, int end): super(line, column, start, end);
  final double value;

  @override
  String toString() => '$value';
}

class _IdentifierToken extends _Token {
  _IdentifierToken(this.value, int line, int column, int start, int end): super(line, column, start, end);
  final String value;

  @override
  String toString() => value;
}

class _StringToken extends _Token {
  _StringToken(this.value, int line, int column, int start, int end): super(line, column, start, end);
  final String value;

  @override
  String toString() => '"$value"';
}

class _EofToken extends _Token {
  _EofToken(super.line, super.column, super.start, super.end);

  @override
  String toString() => '<EOF>';
}

/// Indicates that there an error was detected while parsing a file.
///
/// This is used by [parseDataFile] and [parseLibraryFile] to indicate that the
/// given file has a syntax or semantic error.
///
/// The [line] and [column] describe how far the parser had reached when the
/// error was detected (this may not precisely indicate the actual location of
/// the error).
///
/// The [message] property is a human-readable string describing the error.
class ParserException implements Exception {
  /// Create an instance of [ParserException].
  ///
  /// The arguments must not be null. See [message] for details on
  /// the expected syntax of the error description.
  const ParserException(this.message, this.line, this.column);

  factory ParserException._fromToken(String message, _Token token) {
    return ParserException(message, token.line, token.column);
  }

  factory ParserException._expected(String what, _Token token) {
    return ParserException('Expected $what but found $token', token.line, token.column);
  }

  factory ParserException._unexpected(_Token token) {
    return ParserException('Unexpected $token', token.line, token.column);
  }

  /// The error that was detected by the parser.
  ///
  /// This should be the start of a sentence which will make sense when " at
  /// line ... column ..." is appended. So, for example, it should not end with
  /// a period.
  final String message;

  /// The line number (using 1-based indexing) that the parser had reached when
  /// the error was detected.
  final int line;

  /// The column number (using 1-based indexing) that the parser had reached
  /// when the error was detected.
  ///
  /// This is measured in UTF-16 code units, even if the source file was UTF-8.
  final int column;

  @override
  String toString() => '$message at line $line column $column.';
}

enum _TokenizerMode {
  main,
  minus,
  zero,
  minusInteger,
  integer,
  integerOnly,
  numericDot,
  fraction,
  e,
  negativeExponent,
  exponent,
  x,
  hex,
  dot1,
  dot2,
  identifier,
  quote,
  doubleQuote,
  quoteEscape,
  quoteEscapeUnicode1,
  quoteEscapeUnicode2,
  quoteEscapeUnicode3,
  quoteEscapeUnicode4,
  doubleQuoteEscape,
  doubleQuoteEscapeUnicode1,
  doubleQuoteEscapeUnicode2,
  doubleQuoteEscapeUnicode3,
  doubleQuoteEscapeUnicode4,
  endQuote,
  slash,
  comment,
  blockComment,
  blockCommentEnd,
}

String _describeRune(int current) {
  assert(current >= 0);
  assert(current < 0x10FFFF);
  if (current > 0x20) {
    return 'U+${current.toRadixString(16).toUpperCase().padLeft(4, "0")} ("${String.fromCharCode(current)}")';
  }
  return 'U+${current.toRadixString(16).toUpperCase().padLeft(4, "0")}';
}

Iterable<_Token> _tokenize(String file) sync* {
  final List<int> characters = file.runes.toList();
  int start = 0;
  int index = 0;
  int line = 1;
  int column = 0;
  final List<int> buffer = <int>[];
  final List<int> buffer2 = <int>[];
  _TokenizerMode mode = _TokenizerMode.main;
  while (true) {
    final int current;
    if (index >= characters.length) {
      current = -1;
    } else {
      current = characters[index];
      if (current == 0x0A) {
        line += 1;
        column = 0;
      } else {
        column += 1;
      }
    }
    index += 1;
    switch (mode) {

      case _TokenizerMode.main:
        switch (current) {
          case -1:
            yield _EofToken(line, column, start, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            start = index;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x3E: // U+003E GREATHER THAN SIGN character (>)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _SymbolToken(current, line, column, start, index);
            start = index;
          case 0x22: // U+0022 QUOTATION MARK character (")
            assert(buffer.isEmpty);
            mode = _TokenizerMode.doubleQuote;
          case 0x27: // U+0027 APOSTROPHE character (')
            assert(buffer.isEmpty);
            mode = _TokenizerMode.quote;
          case 0x2D: // U+002D HYPHEN-MINUS character (-)
            assert(buffer.isEmpty);
            mode = _TokenizerMode.minus;
            buffer.add(current);
          case 0x2E: // U+002E FULL STOP character (.)
            mode = _TokenizerMode.dot1;
          case 0x2F: // U+002F SOLIDUS character (/)
            mode = _TokenizerMode.slash;
          case 0x30: // U+0030 DIGIT ZERO character (0)
            assert(buffer.isEmpty);
            mode = _TokenizerMode.zero;
            buffer.add(current);
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            assert(buffer.isEmpty);
            mode = _TokenizerMode.integer;
            buffer.add(current);
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x47: // U+0047 LATIN CAPITAL LETTER G character
          case 0x48: // U+0048 LATIN CAPITAL LETTER H character
          case 0x49: // U+0049 LATIN CAPITAL LETTER I character
          case 0x4A: // U+004A LATIN CAPITAL LETTER J character
          case 0x4B: // U+004B LATIN CAPITAL LETTER K character
          case 0x4C: // U+004C LATIN CAPITAL LETTER L character
          case 0x4D: // U+004D LATIN CAPITAL LETTER M character
          case 0x4E: // U+004E LATIN CAPITAL LETTER N character
          case 0x4F: // U+004F LATIN CAPITAL LETTER O character
          case 0x50: // U+0050 LATIN CAPITAL LETTER P character
          case 0x51: // U+0051 LATIN CAPITAL LETTER Q character
          case 0x52: // U+0052 LATIN CAPITAL LETTER R character
          case 0x53: // U+0053 LATIN CAPITAL LETTER S character
          case 0x54: // U+0054 LATIN CAPITAL LETTER T character
          case 0x55: // U+0055 LATIN CAPITAL LETTER U character
          case 0x56: // U+0056 LATIN CAPITAL LETTER V character
          case 0x57: // U+0057 LATIN CAPITAL LETTER W character
          case 0x58: // U+0058 LATIN CAPITAL LETTER X character
          case 0x59: // U+0059 LATIN CAPITAL LETTER Y character
          case 0x5A: // U+005A LATIN CAPITAL LETTER Z character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
          case 0x67: // U+0067 LATIN SMALL LETTER G character
          case 0x68: // U+0068 LATIN SMALL LETTER H character
          case 0x69: // U+0069 LATIN SMALL LETTER I character
          case 0x6A: // U+006A LATIN SMALL LETTER J character
          case 0x6B: // U+006B LATIN SMALL LETTER K character
          case 0x6C: // U+006C LATIN SMALL LETTER L character
          case 0x6D: // U+006D LATIN SMALL LETTER M character
          case 0x6E: // U+006E LATIN SMALL LETTER N character
          case 0x6F: // U+006F LATIN SMALL LETTER O character
          case 0x70: // U+0070 LATIN SMALL LETTER P character
          case 0x71: // U+0071 LATIN SMALL LETTER Q character
          case 0x72: // U+0072 LATIN SMALL LETTER R character
          case 0x73: // U+0073 LATIN SMALL LETTER S character
          case 0x74: // U+0074 LATIN SMALL LETTER T character
          case 0x75: // U+0075 LATIN SMALL LETTER U character
          case 0x76: // U+0076 LATIN SMALL LETTER V character
          case 0x77: // U+0077 LATIN SMALL LETTER W character
          case 0x78: // U+0078 LATIN SMALL LETTER X character
          case 0x79: // U+0079 LATIN SMALL LETTER Y character
          case 0x7A: // U+007A LATIN SMALL LETTER Z character
          case 0x5F: // U+005F LOW LINE character (_)
            assert(buffer.isEmpty);
            mode = _TokenizerMode.identifier;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)}', line, column);
        }

      case _TokenizerMode.minus: // "-"
        assert(buffer.length == 1 && buffer[0] == 0x2D);
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file after minus sign', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            mode = _TokenizerMode.minusInteger;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} after minus sign (expected digit)', line, column);
        }

      case _TokenizerMode.zero: // "0"
        assert(buffer.length == 1 && buffer[0] == 0x30);
        switch (current) {
          case -1:
            yield _IntegerToken(0, line, column, start, index - 1);
            yield _EofToken(line, column, index - 1, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            yield _IntegerToken(0, line, column, start, index - 1);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.main;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _IntegerToken(0, line, column, start, index - 1);
            buffer.clear();
            yield _SymbolToken(current, line, column, index - 1, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x2E: // U+002E FULL STOP character (.)
            mode = _TokenizerMode.numericDot;
            buffer.add(current);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            mode = _TokenizerMode.integer;
            buffer.add(current);
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
            mode = _TokenizerMode.e;
            buffer.add(current);
          case 0x58: // U+0058 LATIN CAPITAL LETTER X character
          case 0x78: // U+0078 LATIN SMALL LETTER X character
            mode = _TokenizerMode.x;
            buffer.clear();
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} after zero', line, column);
        }

      case _TokenizerMode.minusInteger: // "-0"
        switch (current) {
          case -1:
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            yield _EofToken(line, column, index - 1, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.main;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            buffer.clear();
            yield _SymbolToken(current, line, column, index - 1, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x2E: // U+002E FULL STOP character (.)
            mode = _TokenizerMode.numericDot;
            buffer.add(current);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            mode = _TokenizerMode.integer;
            buffer.add(current);
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
            mode = _TokenizerMode.e;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} after negative zero', line, column);
        }

      case _TokenizerMode.integer: // "00", "1", "-00"
        switch (current) {
          case -1:
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            buffer.clear();
            yield _EofToken(line, column, index - 1, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.main;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            buffer.clear();
            yield _SymbolToken(current, line, column, index - 1, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x2E: // U+002E FULL STOP character (.)
            mode = _TokenizerMode.numericDot;
            buffer.add(current);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            buffer.add(current);
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
            mode = _TokenizerMode.e;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)}', line, column);
        }

      case _TokenizerMode.integerOnly:
        switch (current) {
          case -1:
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            buffer.clear();
            yield _EofToken(line, column, index - 1, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.main;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            buffer.clear();
            yield _SymbolToken(current, line, column, index - 1, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x2E: // U+002E FULL STOP character (.)
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 10), line, column, start, index - 1);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.dot1;
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            buffer.add(current); // https://github.com/dart-lang/sdk/issues/53349
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in integer', line, column);
        }

      case _TokenizerMode.numericDot: // "0.", "-0.", "00.", "1.", "-00."
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file after decimal point', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            mode = _TokenizerMode.fraction;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in fraction component', line, column);
        }

      case _TokenizerMode.fraction: // "0.0", "-0.0", "00.0", "1.0", "-00.0"
        switch (current) {
          case -1:
            yield _DoubleToken(double.parse(String.fromCharCodes(buffer)), line, column, start, index - 1);
            yield _EofToken(line, column, index - 1, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            yield _DoubleToken(double.parse(String.fromCharCodes(buffer)), line, column, start, index - 1);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.main;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _DoubleToken(double.parse(String.fromCharCodes(buffer)), line, column, start, index - 1);
            buffer.clear();
            yield _SymbolToken(current, line, column, index - 1, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            buffer.add(current);
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
            mode = _TokenizerMode.e;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in fraction component', line, column);
        }

      case _TokenizerMode.e: // "0e", "-0e", "00e", "1e", "-00e", "0.0e", "-0.0e", "00.0e", "1.0e", "-00.0e"
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file after exponent separator', line, column);
          case 0x2D: // U+002D HYPHEN-MINUS character (-)
            mode = _TokenizerMode.negativeExponent;
            buffer.add(current);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            mode = _TokenizerMode.exponent;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} after exponent separator', line, column);
        }

      case _TokenizerMode.negativeExponent: // "0e-", "-0e-", "00e-", "1e-", "-00e-", "0.0e-", "-0.0e-", "00.0e-", "1.0e-", "-00.0e-"
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file after exponent separator and minus sign', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            mode = _TokenizerMode.exponent;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in exponent', line, column);
        }

      case _TokenizerMode.exponent: // "0e0", "-0e0", "00e0", "1e0", "-00e0", "0.0e0", "-0.0e0", "00.0e0", "1.0e0", "-00.0e0", "0e-0", "-0e-0", "00e-0", "1e-0", "-00e-0", "0.0e-0", "-0.0e-0", "00.0e-0", "1.0e-0", "-00.0e-0"
        switch (current) {
          case -1:
            yield _DoubleToken(double.parse(String.fromCharCodes(buffer)), line, column, start, index - 1);
            yield _EofToken(line, column, index - 1, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            yield _DoubleToken(double.parse(String.fromCharCodes(buffer)), line, column, start, index - 1);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.main;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _DoubleToken(double.parse(String.fromCharCodes(buffer)), line, column, start, index - 1);
            buffer.clear();
            yield _SymbolToken(current, line, column, index - 1, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in exponent', line, column);
        }

      case _TokenizerMode.x: // "0x", "0X"
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file after 0x prefix', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            mode = _TokenizerMode.hex;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} after 0x prefix', line, column);
        }

      case _TokenizerMode.hex:
        switch (current) {
          case -1:
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 16), line, column, start, index - 1);
            yield _EofToken(line, column, index - 1, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 16), line, column, start, index - 1);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.main;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _IntegerToken(int.parse(String.fromCharCodes(buffer), radix: 16), line, column, start, index - 1);
            buffer.clear();
            yield _SymbolToken(current, line, column, index - 1, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in hex literal', line, column);
        }

      case _TokenizerMode.dot1: // "."
        switch (current) {
          case -1:
            yield _SymbolToken(0x2E, line, column, start, index - 1);
            yield _EofToken(line, column, index - 1, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            yield _SymbolToken(0x2E, line, column, start, index - 1);
            start = index;
            mode = _TokenizerMode.main;
          case 0x22: // U+0022 QUOTATION MARK character (")
            yield _SymbolToken(0x2E, line, column, start, index);
            assert(buffer.isEmpty);
            start = index;
            mode = _TokenizerMode.doubleQuote;
          case 0x27: // U+0027 APOSTROPHE character (')
            yield _SymbolToken(0x2E, line, column, start, index);
            assert(buffer.isEmpty);
            start = index;
            mode = _TokenizerMode.quote;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _SymbolToken(0x2E, line, column, start, index - 1);
            yield _SymbolToken(current, line, column, index - 1, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x2E: // U+002E FULL STOP character (.)
            mode = _TokenizerMode.dot2;
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
            yield _SymbolToken(0x2E, line, column, start, index - 1);
            assert(buffer.isEmpty);
            start = index - 1;
            mode = _TokenizerMode.integerOnly;
            buffer.add(current);
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x47: // U+0047 LATIN CAPITAL LETTER G character
          case 0x48: // U+0048 LATIN CAPITAL LETTER H character
          case 0x49: // U+0049 LATIN CAPITAL LETTER I character
          case 0x4A: // U+004A LATIN CAPITAL LETTER J character
          case 0x4B: // U+004B LATIN CAPITAL LETTER K character
          case 0x4C: // U+004C LATIN CAPITAL LETTER L character
          case 0x4D: // U+004D LATIN CAPITAL LETTER M character
          case 0x4E: // U+004E LATIN CAPITAL LETTER N character
          case 0x4F: // U+004F LATIN CAPITAL LETTER O character
          case 0x50: // U+0050 LATIN CAPITAL LETTER P character
          case 0x51: // U+0051 LATIN CAPITAL LETTER Q character
          case 0x52: // U+0052 LATIN CAPITAL LETTER R character
          case 0x53: // U+0053 LATIN CAPITAL LETTER S character
          case 0x54: // U+0054 LATIN CAPITAL LETTER T character
          case 0x55: // U+0055 LATIN CAPITAL LETTER U character
          case 0x56: // U+0056 LATIN CAPITAL LETTER V character
          case 0x57: // U+0057 LATIN CAPITAL LETTER W character
          case 0x58: // U+0058 LATIN CAPITAL LETTER X character
          case 0x59: // U+0059 LATIN CAPITAL LETTER Y character
          case 0x5A: // U+005A LATIN CAPITAL LETTER Z character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
          case 0x67: // U+0067 LATIN SMALL LETTER G character
          case 0x68: // U+0068 LATIN SMALL LETTER H character
          case 0x69: // U+0069 LATIN SMALL LETTER I character
          case 0x6A: // U+006A LATIN SMALL LETTER J character
          case 0x6B: // U+006B LATIN SMALL LETTER K character
          case 0x6C: // U+006C LATIN SMALL LETTER L character
          case 0x6D: // U+006D LATIN SMALL LETTER M character
          case 0x6E: // U+006E LATIN SMALL LETTER N character
          case 0x6F: // U+006F LATIN SMALL LETTER O character
          case 0x70: // U+0070 LATIN SMALL LETTER P character
          case 0x71: // U+0071 LATIN SMALL LETTER Q character
          case 0x72: // U+0072 LATIN SMALL LETTER R character
          case 0x73: // U+0073 LATIN SMALL LETTER S character
          case 0x74: // U+0074 LATIN SMALL LETTER T character
          case 0x75: // U+0075 LATIN SMALL LETTER U character
          case 0x76: // U+0076 LATIN SMALL LETTER V character
          case 0x77: // U+0077 LATIN SMALL LETTER W character
          case 0x78: // U+0078 LATIN SMALL LETTER X character
          case 0x79: // U+0079 LATIN SMALL LETTER Y character
          case 0x7A: // U+007A LATIN SMALL LETTER Z character
          case 0x5F: // U+005F LOW LINE character (_)
            yield _SymbolToken(0x2E, line, column, start, index - 1);
            assert(buffer.isEmpty);
            start = index - 1;
            mode = _TokenizerMode.identifier;
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} after period', line, column);
        }

      case _TokenizerMode.dot2: // ".."
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside "..." symbol', line, column);
          case 0x2E: // U+002E FULL STOP character (.)
            yield _SymbolToken(_SymbolToken.tripleDot, line, column, start, index);
            start = index;
            mode = _TokenizerMode.main;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} inside "..." symbol', line, column);
        }

      case _TokenizerMode.identifier:
        switch (current) {
          case -1:
            yield _IdentifierToken(String.fromCharCodes(buffer), line, column, start, index - 1);
            yield _EofToken(line, column, index - 1, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            yield _IdentifierToken(String.fromCharCodes(buffer), line, column, start, index - 1);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.main;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _IdentifierToken(String.fromCharCodes(buffer), line, column, start, index - 1);
            buffer.clear();
            yield _SymbolToken(current, line, column, index - 1, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x2E: // U+002E FULL STOP character (.)
            yield _IdentifierToken(String.fromCharCodes(buffer), line, column, start, index);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.dot1;
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x47: // U+0047 LATIN CAPITAL LETTER G character
          case 0x48: // U+0048 LATIN CAPITAL LETTER H character
          case 0x49: // U+0049 LATIN CAPITAL LETTER I character
          case 0x4A: // U+004A LATIN CAPITAL LETTER J character
          case 0x4B: // U+004B LATIN CAPITAL LETTER K character
          case 0x4C: // U+004C LATIN CAPITAL LETTER L character
          case 0x4D: // U+004D LATIN CAPITAL LETTER M character
          case 0x4E: // U+004E LATIN CAPITAL LETTER N character
          case 0x4F: // U+004F LATIN CAPITAL LETTER O character
          case 0x50: // U+0050 LATIN CAPITAL LETTER P character
          case 0x51: // U+0051 LATIN CAPITAL LETTER Q character
          case 0x52: // U+0052 LATIN CAPITAL LETTER R character
          case 0x53: // U+0053 LATIN CAPITAL LETTER S character
          case 0x54: // U+0054 LATIN CAPITAL LETTER T character
          case 0x55: // U+0055 LATIN CAPITAL LETTER U character
          case 0x56: // U+0056 LATIN CAPITAL LETTER V character
          case 0x57: // U+0057 LATIN CAPITAL LETTER W character
          case 0x58: // U+0058 LATIN CAPITAL LETTER X character
          case 0x59: // U+0059 LATIN CAPITAL LETTER Y character
          case 0x5A: // U+005A LATIN CAPITAL LETTER Z character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
          case 0x67: // U+0067 LATIN SMALL LETTER G character
          case 0x68: // U+0068 LATIN SMALL LETTER H character
          case 0x69: // U+0069 LATIN SMALL LETTER I character
          case 0x6A: // U+006A LATIN SMALL LETTER J character
          case 0x6B: // U+006B LATIN SMALL LETTER K character
          case 0x6C: // U+006C LATIN SMALL LETTER L character
          case 0x6D: // U+006D LATIN SMALL LETTER M character
          case 0x6E: // U+006E LATIN SMALL LETTER N character
          case 0x6F: // U+006F LATIN SMALL LETTER O character
          case 0x70: // U+0070 LATIN SMALL LETTER P character
          case 0x71: // U+0071 LATIN SMALL LETTER Q character
          case 0x72: // U+0072 LATIN SMALL LETTER R character
          case 0x73: // U+0073 LATIN SMALL LETTER S character
          case 0x74: // U+0074 LATIN SMALL LETTER T character
          case 0x75: // U+0075 LATIN SMALL LETTER U character
          case 0x76: // U+0076 LATIN SMALL LETTER V character
          case 0x77: // U+0077 LATIN SMALL LETTER W character
          case 0x78: // U+0078 LATIN SMALL LETTER X character
          case 0x79: // U+0079 LATIN SMALL LETTER Y character
          case 0x7A: // U+007A LATIN SMALL LETTER Z character
          case 0x5F: // U+005F LOW LINE character (_)
            buffer.add(current);
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} inside identifier', line, column);
        }

      case _TokenizerMode.quote:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside string', line, column);
          case 0x0A: // U+000A LINE FEED (LF)
            throw ParserException('Unexpected end of line inside string', line, column);
          case 0x27: // U+0027 APOSTROPHE character (')
            yield _StringToken(String.fromCharCodes(buffer), line, column, start, index);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.endQuote;
          case 0x5C: // U+005C REVERSE SOLIDUS character (\)
            mode = _TokenizerMode.quoteEscape;
          default:
            buffer.add(current);
        }

      case _TokenizerMode.quoteEscape:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside string', line, column);
          case 0x22: // U+0022 QUOTATION MARK character (")
          case 0x27: // U+0027 APOSTROPHE character (')
          case 0x5C: // U+005C REVERSE SOLIDUS character (\)
          case 0x2F: // U+002F SOLIDUS character (/)
            buffer.add(current);
            mode = _TokenizerMode.quote;
          case 0x62: // U+0062 LATIN SMALL LETTER B character
            buffer.add(0x08);
            mode = _TokenizerMode.quote;
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer.add(0x0C);
            mode = _TokenizerMode.quote;
          case 0x6E: // U+006E LATIN SMALL LETTER N character
            buffer.add(0x0A);
            mode = _TokenizerMode.quote;
          case 0x72: // U+0072 LATIN SMALL LETTER R character
            buffer.add(0x0D);
            mode = _TokenizerMode.quote;
          case 0x74: // U+0074 LATIN SMALL LETTER T character
            buffer.add(0x09);
            mode = _TokenizerMode.quote;
          case 0x75: // U+0075 LATIN SMALL LETTER U character
            assert(buffer2.isEmpty);
            mode = _TokenizerMode.quoteEscapeUnicode1;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} after backslash in string', line, column);
        }

      case _TokenizerMode.quoteEscapeUnicode1:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside Unicode escape', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer2.add(current);
            mode = _TokenizerMode.quoteEscapeUnicode2;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in Unicode escape', line, column);
        }

      case _TokenizerMode.quoteEscapeUnicode2:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside Unicode escape', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer2.add(current);
            mode = _TokenizerMode.quoteEscapeUnicode3;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in Unicode escape', line, column);
        }

      case _TokenizerMode.quoteEscapeUnicode3:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside Unicode escape', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer2.add(current);
            mode = _TokenizerMode.quoteEscapeUnicode4;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in Unicode escape', line, column);
        }

      case _TokenizerMode.quoteEscapeUnicode4:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside Unicode escape', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer2.add(current);
            buffer.add(int.parse(String.fromCharCodes(buffer2), radix: 16));
            buffer2.clear();
            mode = _TokenizerMode.quote;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in Unicode escape', line, column);
        }

      case _TokenizerMode.doubleQuote:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside string', line, column);
          case 0x0A: // U+000A LINE FEED (LF)
            throw ParserException('Unexpected end of line inside string', line, column);
          case 0x22: // U+0022 QUOTATION MARK character (")
            yield _StringToken(String.fromCharCodes(buffer), line, column, start, index);
            buffer.clear();
            start = index;
            mode = _TokenizerMode.endQuote;
          case 0x5C: // U+005C REVERSE SOLIDUS character (\)
            mode = _TokenizerMode.doubleQuoteEscape;
          default:
            buffer.add(current);
        }

      case _TokenizerMode.doubleQuoteEscape:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside string', line, column);
          case 0x22: // U+0022 QUOTATION MARK character (")
          case 0x27: // U+0027 APOSTROPHE character (')
          case 0x5C: // U+005C REVERSE SOLIDUS character (\)
          case 0x2F: // U+002F SOLIDUS character (/)
            buffer.add(current);
            mode = _TokenizerMode.doubleQuote;
          case 0x62: // U+0062 LATIN SMALL LETTER B character
            buffer.add(0x08);
            mode = _TokenizerMode.doubleQuote;
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer.add(0x0C);
            mode = _TokenizerMode.doubleQuote;
          case 0x6E: // U+006E LATIN SMALL LETTER N character
            buffer.add(0x0A);
            mode = _TokenizerMode.doubleQuote;
          case 0x72: // U+0072 LATIN SMALL LETTER R character
            buffer.add(0x0D);
            mode = _TokenizerMode.doubleQuote;
          case 0x74: // U+0074 LATIN SMALL LETTER T character
            buffer.add(0x09);
            mode = _TokenizerMode.doubleQuote;
          case 0x75: // U+0075 LATIN SMALL LETTER U character
            assert(buffer2.isEmpty);
            mode = _TokenizerMode.doubleQuoteEscapeUnicode1;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} after backslash in string', line, column);
        }

      case _TokenizerMode.doubleQuoteEscapeUnicode1:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside Unicode escape', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer2.add(current);
            mode = _TokenizerMode.doubleQuoteEscapeUnicode2;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in Unicode escape', line, column);
        }

      case _TokenizerMode.doubleQuoteEscapeUnicode2:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside Unicode escape', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer2.add(current);
            mode = _TokenizerMode.doubleQuoteEscapeUnicode3;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in Unicode escape', line, column);
        }

      case _TokenizerMode.doubleQuoteEscapeUnicode3:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside Unicode escape', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer2.add(current);
            mode = _TokenizerMode.doubleQuoteEscapeUnicode4;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in Unicode escape', line, column);
        }

      case _TokenizerMode.doubleQuoteEscapeUnicode4:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside Unicode escape', line, column);
          case 0x30: // U+0030 DIGIT ZERO character (0)
          case 0x31: // U+0031 DIGIT ONE character (1)
          case 0x32: // U+0032 DIGIT TWO character (2)
          case 0x33: // U+0033 DIGIT THREE character (3)
          case 0x34: // U+0034 DIGIT FOUR character (4)
          case 0x35: // U+0035 DIGIT FIVE character (5)
          case 0x36: // U+0036 DIGIT SIX character (6)
          case 0x37: // U+0037 DIGIT SEVEN character (7)
          case 0x38: // U+0038 DIGIT EIGHT character (8)
          case 0x39: // U+0039 DIGIT NINE character (9)
          case 0x41: // U+0041 LATIN CAPITAL LETTER A character
          case 0x42: // U+0042 LATIN CAPITAL LETTER B character
          case 0x43: // U+0043 LATIN CAPITAL LETTER C character
          case 0x44: // U+0044 LATIN CAPITAL LETTER D character
          case 0x45: // U+0045 LATIN CAPITAL LETTER E character
          case 0x46: // U+0046 LATIN CAPITAL LETTER F character
          case 0x61: // U+0061 LATIN SMALL LETTER A character
          case 0x62: // U+0062 LATIN SMALL LETTER B character
          case 0x63: // U+0063 LATIN SMALL LETTER C character
          case 0x64: // U+0064 LATIN SMALL LETTER D character
          case 0x65: // U+0065 LATIN SMALL LETTER E character
          case 0x66: // U+0066 LATIN SMALL LETTER F character
            buffer2.add(current);
            buffer.add(int.parse(String.fromCharCodes(buffer2), radix: 16));
            buffer2.clear();
            mode = _TokenizerMode.doubleQuote;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} in Unicode escape', line, column);
        }

      case _TokenizerMode.endQuote:
        switch (current) {
          case -1:
            yield _EofToken(line, column, start, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
          case 0x20: // U+0020 SPACE character
            start = index;
            mode = _TokenizerMode.main;
          case 0x28: // U+0028 LEFT PARENTHESIS character (()
          case 0x29: // U+0029 RIGHT PARENTHESIS character ())
          case 0x2C: // U+002C COMMA character (,)
          case 0x3A: // U+003A COLON character (:)
          case 0x3B: // U+003B SEMICOLON character (;)
          case 0x3D: // U+003D EQUALS SIGN character (=)
          case 0x5B: // U+005B LEFT SQUARE BRACKET character ([)
          case 0x5D: // U+005D RIGHT SQUARE BRACKET character (])
          case 0x7B: // U+007B LEFT CURLY BRACKET character ({)
          case 0x7D: // U+007D RIGHT CURLY BRACKET character (})
            yield _SymbolToken(current, line, column, start, index);
            start = index;
            mode = _TokenizerMode.main;
          case 0x2E: // U+002E FULL STOP character (.)
            mode = _TokenizerMode.dot1;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} after end quote', line, column);
        }

      case _TokenizerMode.slash:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file inside comment delimiter', line, column);
          case 0x2A: // U+002A ASTERISK character (*)
            mode = _TokenizerMode.blockComment;
          case 0x2F: // U+002F SOLIDUS character (/)
            mode = _TokenizerMode.comment;
          default:
            throw ParserException('Unexpected character ${_describeRune(current)} inside comment delimiter', line, column);
        }

      case _TokenizerMode.comment:
        switch (current) {
          case -1:
            yield _EofToken(line, column, start, index);
            return;
          case 0x0A: // U+000A LINE FEED (LF)
            mode = _TokenizerMode.main;
          default:
            // ignored, comment
            break;
        }

      case _TokenizerMode.blockComment:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file in block comment', line, column);
          case 0x2A: // U+002A ASTERISK character (*)
            mode = _TokenizerMode.blockCommentEnd;
          default:
            // ignored, comment
            break;
        }

      case _TokenizerMode.blockCommentEnd:
        switch (current) {
          case -1:
            throw ParserException('Unexpected end of file in block comment', line, column);
          case 0x2F: // U+002F SOLIDUS character (/)
            mode = _TokenizerMode.main;
          default:
            // ignored, comment
            mode = _TokenizerMode.blockComment;
        }
    }
  }
}

/// API for parsing Remote Flutter Widgets text files.
///
/// Text data files can be parsed by using [readDataFile]. (Unlike the binary
/// variant of this format, the root of a text data file is always a map.)
///
/// Test library files can be parsed by using [readLibraryFile].
class _Parser {
  _Parser(Iterable<_Token> source, this.sourceIdentifier) : _source = source.iterator..moveNext();

  final Iterator<_Token> _source;
  final Object? sourceIdentifier;

  int _previousEnd = 0;

  void _advance() {
    assert(_source.current is! _EofToken);
    _previousEnd = _source.current.end;
    final bool advanced = _source.moveNext();
    assert(advanced);
  }

  SourceLocation? _getSourceLocation() {
    if (sourceIdentifier != null) {
      return SourceLocation(sourceIdentifier!, _source.current.start);
    }
    return null;
  }

  T _withSourceRange<T extends BlobNode>(T node, SourceLocation? start) {
    if (sourceIdentifier != null && start != null) {
      node.associateSource(SourceRange(
        start,
        SourceLocation(sourceIdentifier!, _previousEnd),
      ));
    }
    return node;
  }

  bool _foundIdentifier(String identifier) {
    return (_source.current is _IdentifierToken)
        && ((_source.current as _IdentifierToken).value == identifier);
  }

  void _expectIdentifier(String value) {
    if (_source.current is! _IdentifierToken) {
      throw ParserException._expected('identifier', _source.current);
    }
    if ((_source.current as _IdentifierToken).value != value) {
      throw ParserException._expected(value, _source.current);
    }
    _advance();
  }

  String _readIdentifier() {
    if (_source.current is! _IdentifierToken) {
      throw ParserException._expected('identifier', _source.current);
    }
    final String result = (_source.current as _IdentifierToken).value;
    _advance();
    return result;
  }

  String _readString() {
    if (_source.current is! _StringToken) {
      throw ParserException._expected('string', _source.current);
    }
    final String result = (_source.current as _StringToken).value;
    _advance();
    return result;
  }

  bool _foundSymbol(int symbol) {
    return (_source.current is _SymbolToken)
        && ((_source.current as _SymbolToken).symbol == symbol);
  }

  bool _maybeReadSymbol(int symbol) {
    if (_foundSymbol(symbol)) {
      _advance();
      return true;
    }
    return false;
  }

  void _expectSymbol(int symbol) {
    if (_source.current is! _SymbolToken) {
      throw ParserException._expected('symbol "${String.fromCharCode(symbol)}"', _source.current);
    }
    if ((_source.current as _SymbolToken).symbol != symbol) {
      throw ParserException._expected('symbol "${String.fromCharCode(symbol)}"', _source.current);
    }
    _advance();
  }

  String _readKey() {
    if (_source.current is _IdentifierToken) {
      return _readIdentifier();
    }
    return _readString();
  }

  DynamicMap _readMap({
    required bool extended,
    List<String> widgetBuilderScope = const <String>[],
  }) {
    _expectSymbol(_SymbolToken.openBrace);
    final DynamicMap results = _readMapBody(
      widgetBuilderScope: widgetBuilderScope,
      extended: extended,
    );
    _expectSymbol(_SymbolToken.closeBrace);
    return results;
  }

  DynamicMap _readMapBody({
    required bool extended,
    List<String> widgetBuilderScope = const <String>[],
  }) {
    final DynamicMap results = DynamicMap(); // ignore: prefer_collection_literals
    while (_source.current is! _SymbolToken) {
      final String key = _readKey();
      if (results.containsKey(key)) {
        throw ParserException._fromToken('Duplicate key "$key" in map', _source.current);
      }
      _expectSymbol(_SymbolToken.colon);
      final Object value = _readValue(
        extended: extended,
        nullOk: true,
        widgetBuilderScope: widgetBuilderScope,
      );
      if (value != missing) {
        results[key] = value;
      }
      if (_foundSymbol(_SymbolToken.comma)) {
        _advance();
      } else {
        break;
      }
    }
    return results;
  }

  final List<String> _loopIdentifiers = <String>[];

  DynamicList _readList({
    required bool extended,
    List<String> widgetBuilderScope = const <String>[],
  }) {
    final DynamicList results = DynamicList.empty(growable: true);
    _expectSymbol(_SymbolToken.openBracket);
    while (!_foundSymbol(_SymbolToken.closeBracket)) {
      if (extended && _foundSymbol(_SymbolToken.tripleDot)) {
        final SourceLocation? start = _getSourceLocation();
        _advance();
        _expectIdentifier('for');
        final _Token loopIdentifierToken = _source.current;
        final String loopIdentifier = _readIdentifier();
        _checkIsNotReservedWord(loopIdentifier, loopIdentifierToken);
        _expectIdentifier('in');
        final Object collection = _readValue(
          widgetBuilderScope: widgetBuilderScope,
          extended: true,
        );
        _expectSymbol(_SymbolToken.colon);
        _loopIdentifiers.add(loopIdentifier);
        final Object template = _readValue(
          widgetBuilderScope: widgetBuilderScope,
          extended: extended,
        );
        assert(_loopIdentifiers.last == loopIdentifier);
        _loopIdentifiers.removeLast();
        results.add(_withSourceRange(Loop(collection, template), start));
      } else {
        final Object value = _readValue(
          widgetBuilderScope: widgetBuilderScope,
          extended: extended,
        );
        results.add(value);
      }
      if (_foundSymbol(_SymbolToken.comma)) {
        _advance();
      } else if (!_foundSymbol(_SymbolToken.closeBracket)) {
        throw ParserException._expected('comma', _source.current);
      }
    }
    _expectSymbol(_SymbolToken.closeBracket);
    return results;
  }

  Switch _readSwitch(SourceLocation? start, {
    List<String> widgetBuilderScope = const <String>[],
  }) {
    final Object value = _readValue(extended: true, widgetBuilderScope: widgetBuilderScope);
    final Map<Object?, Object> cases = <Object?, Object>{};
    _expectSymbol(_SymbolToken.openBrace);
    while (_source.current is! _SymbolToken) {
      final Object? key;
      if (_foundIdentifier('default')) {
        if (cases.containsKey(null)) {
          throw ParserException._fromToken('Switch has multiple default cases', _source.current);
        }
        key = null;
        _advance();
      } else {
        key = _readValue(extended: true, widgetBuilderScope: widgetBuilderScope);
        if (cases.containsKey(key)) {
          throw ParserException._fromToken('Switch has duplicate cases for key $key', _source.current);
        }
      }
      _expectSymbol(_SymbolToken.colon);
      final Object value = _readValue(extended: true, widgetBuilderScope: widgetBuilderScope);
      cases[key] = value;
      if (_foundSymbol(_SymbolToken.comma)) {
        _advance();
      } else {
        break;
      }
    }
    _expectSymbol(_SymbolToken.closeBrace);
    return _withSourceRange(Switch(value, cases), start);
  }

  List<Object> _readParts({ bool optional = false }) {
    if (optional && !_foundSymbol(_SymbolToken.dot)) {
      return const <Object>[];
    }
    final List<Object> results = <Object>[];
    do {
      _expectSymbol(_SymbolToken.dot);
      if (_source.current is _IntegerToken) {
        results.add((_source.current as _IntegerToken).value);
      } else if (_source.current is _StringToken) {
        results.add((_source.current as _StringToken).value);
      } else if (_source.current is _IdentifierToken) {
        results.add((_source.current as _IdentifierToken).value);
      } else {
        throw ParserException._unexpected(_source.current);
      }
      _advance();
    } while (_foundSymbol(_SymbolToken.dot));
    return results;
  }

  Object _readValue({
    required bool extended,
    bool nullOk = false,
    List<String> widgetBuilderScope = const <String>[],
  }) {
    if (_source.current is _SymbolToken) {
      switch ((_source.current as _SymbolToken).symbol) {
        case _SymbolToken.openBracket:
          return _readList(widgetBuilderScope: widgetBuilderScope, extended: extended);
        case _SymbolToken.openBrace:
          return _readMap(widgetBuilderScope: widgetBuilderScope, extended: extended);
        case _SymbolToken.openParen:
          return _readWidgetBuilderDeclaration(widgetBuilderScope: widgetBuilderScope);
      }
    } else if (_source.current is _IntegerToken) {
      final Object result = (_source.current as _IntegerToken).value;
      _advance();
      return result;
    } else if (_source.current is _DoubleToken) {
      final Object result = (_source.current as _DoubleToken).value;
      _advance();
      return result;
    } else if (_source.current is _StringToken) {
      final Object result = (_source.current as _StringToken).value;
      _advance();
      return result;
    } else if (_source.current is _IdentifierToken) {
      final String identifier = (_source.current as _IdentifierToken).value;
      if (identifier == 'true') {
        _advance();
        return true;
      }
      if (identifier == 'false') {
        _advance();
        return false;
      }
      if (identifier == 'null' && nullOk) {
        _advance();
        return missing;
      }
      if (!extended) {
        throw ParserException._unexpected(_source.current);
      }
      if (identifier == 'event') {
        final SourceLocation? start = _getSourceLocation();
        _advance();
        return _withSourceRange(
          EventHandler(
            _readString(),
            _readMap(widgetBuilderScope: widgetBuilderScope, extended: true),
          ),
          start,
        );
      }
      if (identifier == 'args') {
        final SourceLocation? start = _getSourceLocation();
        _advance();
        return _withSourceRange(ArgsReference(_readParts()), start);
      }
      if (identifier == 'data') {
        final SourceLocation? start = _getSourceLocation();
        _advance();
        return _withSourceRange(DataReference(_readParts()), start);
      }
      if (identifier == 'state') {
        final SourceLocation? start = _getSourceLocation();
        _advance();
        return _withSourceRange(StateReference(_readParts()), start);
      }
      if (identifier == 'switch') {
        final SourceLocation? start = _getSourceLocation();
        _advance();
        return _readSwitch(start, widgetBuilderScope: widgetBuilderScope);
      }
      if (identifier == 'set') {
        final SourceLocation? start = _getSourceLocation();
        _advance();
        final SourceLocation? innerStart = _getSourceLocation();
        _expectIdentifier('state');
        final StateReference stateReference = _withSourceRange(StateReference(_readParts()), innerStart);
        _expectSymbol(_SymbolToken.equals);
        final Object value = _readValue(widgetBuilderScope: widgetBuilderScope, extended: true);
        return _withSourceRange(SetStateHandler(stateReference, value), start);
      }
      if (widgetBuilderScope.contains(identifier)) {
        final SourceLocation? start = _getSourceLocation();
        _advance();
        return _withSourceRange(WidgetBuilderArgReference(identifier, _readParts()), start);
      }
      final int index = _loopIdentifiers.lastIndexOf(identifier) + 1;
      if (index > 0) {
        final SourceLocation? start = _getSourceLocation();
        _advance();
        return _withSourceRange(LoopReference(_loopIdentifiers.length - index, _readParts(optional: true)), start);
      }
      return _readConstructorCall(widgetBuilderScope: widgetBuilderScope);
    }
    throw ParserException._unexpected(_source.current);
  }

  WidgetBuilderDeclaration _readWidgetBuilderDeclaration({
    List<String> widgetBuilderScope = const <String>[],
  }) {
    _expectSymbol(_SymbolToken.openParen);
    final _Token argumentNameToken = _source.current;
    final String argumentName = _readIdentifier();
    _checkIsNotReservedWord(argumentName, argumentNameToken);
    _expectSymbol(_SymbolToken.closeParen);
    _expectSymbol(_SymbolToken.equals);
    _expectSymbol(_SymbolToken.greatherThan);
    final _Token valueToken = _source.current;
    final Object widget = _readValue(
      extended: true,
      widgetBuilderScope: <String>[...widgetBuilderScope, argumentName],
    );
    if (widget is! ConstructorCall && widget is! Switch) {
      throw ParserException._fromToken('Expecting a switch or constructor call got $widget', valueToken);
    }
    return WidgetBuilderDeclaration(argumentName, widget as BlobNode);
  }

  ConstructorCall _readConstructorCall({
    List<String> widgetBuilderScope = const <String>[],
  }) {
    final SourceLocation? start = _getSourceLocation();
    final String name = _readIdentifier();
    _expectSymbol(_SymbolToken.openParen);
    final DynamicMap arguments = _readMapBody(
      extended: true,
      widgetBuilderScope: widgetBuilderScope,
    );
    _expectSymbol(_SymbolToken.closeParen);
    return _withSourceRange(ConstructorCall(name, arguments), start);
  }

  WidgetDeclaration _readWidgetDeclaration() {
    final SourceLocation? start = _getSourceLocation();
    _expectIdentifier('widget');
    final String name = _readIdentifier();
    DynamicMap? initialState;
    if (_foundSymbol(_SymbolToken.openBrace)) {
      initialState = _readMap(extended: false);
    }
    _expectSymbol(_SymbolToken.equals);
    final BlobNode root;
    if (_foundIdentifier('switch')) {
      final SourceLocation? switchStart = _getSourceLocation();
      _advance();
      root = _readSwitch(switchStart);
    } else {
      root = _readConstructorCall();
    }
    _expectSymbol(_SymbolToken.semicolon);
    return _withSourceRange(WidgetDeclaration(name, initialState, root), start);
  }

  Iterable<WidgetDeclaration> _readWidgetDeclarations() sync* {
    while (_foundIdentifier('widget')) {
      yield _readWidgetDeclaration();
    }
  }

  Import _readImport() {
    final SourceLocation? start = _getSourceLocation();
    _expectIdentifier('import');
    final List<String> parts = <String>[];
    do {
      parts.add(_readKey());
    } while (_maybeReadSymbol(_SymbolToken.dot));
    _expectSymbol(_SymbolToken.semicolon);
    return _withSourceRange(Import(LibraryName(parts)), start);
  }

  Iterable<Import> _readImports() sync* {
    while (_foundIdentifier('import')) {
      yield _readImport();
    }
  }

  DynamicMap readDataFile() {
    final DynamicMap result = _readMap(extended: false);
    _expectEof('end of file');
    return result;
  }

  RemoteWidgetLibrary readLibraryFile() {
    final RemoteWidgetLibrary result = RemoteWidgetLibrary(
      _readImports().toList(),
      _readWidgetDeclarations().toList(),
    );
    if (result.widgets.isEmpty) {
      _expectEof('keywords "import" or "widget", or end of file');
    } else {
      _expectEof('keyword "widget" or end of file');
    }
    return result;
  }

  void _expectEof(String expectation) {
    if (_source.current is! _EofToken) {
      throw ParserException._expected(expectation, _source.current);
    }
    final bool more = _source.moveNext();
    assert(!more);
  }
}
