// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

// This file must not import `dart:ui`, directly or indirectly, as it is
// intended to function even in pure Dart server or CLI environments.
import 'package:meta/meta.dart';

/// A map whose keys are strings and whose values are [DynamicMap],
/// [DynamicList], int, double, bool, string, and [BlobNode] objects.
///
/// Part of the data type for [DynamicContent] objects.
typedef DynamicMap = Map<String, Object?>;

/// A list whose values are [DynamicMap], [DynamicList], int, double, bool,
/// string, and [BlobNode] objects.
///
/// Part of the data type for [DynamicContent] objects.
typedef DynamicList = List<Object?>;

/// Reference to a location in a source file.
///
/// This is used in a [SourceRange] object to indicate the location of a
/// [BlobNode] in the original source text.
///
/// Locations are given as offsets (in UTF-16 code units) into the decoded
/// string.
///
/// See also:
///
///  * [BlobNode.source], which exposes the source location of a [BlobNode].
@immutable
class SourceLocation implements Comparable<SourceLocation> {
  /// Create a [SourceLocation] object.
  ///
  /// The [source] and [offset] properties are initialized from the
  /// given arguments.
  const SourceLocation(this.source, this.offset);

  /// An object that identifies the file or other origin of the source.
  ///
  /// For files parsed using [parseLibraryFile], this is the value that
  /// is given as the `sourceIdentifier` argument.
  final Object source;

  /// The offset of the given source location, in UTF-16 code units.
  final int offset;

  @override
  int compareTo(SourceLocation other) {
    if (source != other.source) {
      throw StateError('Cannot compare locations from different sources.');
    }
    return offset - other.offset;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != SourceLocation) {
      return false;
    }
    return other is SourceLocation
        && source == other.source
        && offset == other.offset;
  }

  @override
  int get hashCode => Object.hash(source, offset);

  /// Whether this location is earlier in the file than `other`.
  ///
  /// Can only be used to compare locations in the same [source].
  bool operator <(SourceLocation other) {
    if (source != other.source) {
      throw StateError('Cannot compare locations from different sources.');
    }
    return offset < other.offset;
  }

  /// Whether this location is later in the file than `other`.
  ///
  /// Can only be used to compare locations in the same [source].
  bool operator >(SourceLocation other) {
    if (source != other.source) {
      throw StateError('Cannot compare locations from different sources.');
    }
    return offset > other.offset;
  }

  /// Whether this location is earlier in the file than `other`, or equal to
  /// `other`.
  ///
  /// Can only be used to compare locations in the same [source].
  bool operator <=(SourceLocation other) {
    if (source != other.source) {
      throw StateError('Cannot compare locations from different sources.');
    }
    return offset <= other.offset;
  }

  /// Whether this location is later in the file than `other`, or equal to
  /// `other`.
  ///
  /// Can only be used to compare locations in the same [source].
  bool operator >=(SourceLocation other) {
    if (source != other.source) {
      throw StateError('Cannot compare locations from different sources.');
    }
    return offset >= other.offset;
  }

  @override
  String toString() {
    return '$source@$offset';
  }
}

/// Reference to a range of a source file.
///
/// This is used to indicate the region of a source file that corresponds to a
/// particular [BlobNode].
///
/// By default, [BlobNode]s are not associated with [SourceRange]s. Source
/// location information can be enabled for the [parseLibraryFile] parser by
/// providing the `sourceIdentifier` argument.
///
/// See also:
///
///  * [BlobNode.source], which exposes the source location of a [BlobNode].
@immutable
class SourceRange {
  /// Create a [SourceRange] object.
  ///
  /// The [start] and [end] locations are initialized from the given arguments.
  ///
  /// They must have identical [SourceLocation.source] objects.
  SourceRange(this.start, this.end)
   : assert(start.source == end.source, 'The start and end locations have inconsistent source information.'),
     assert(start < end, 'The start location must be before the end location.');

  /// The start of a contiguous region of a source file that corresponds to a
  /// particular [BlobNode].
  ///
  /// The range contains the start.
  final SourceLocation start;

  /// The end of a contiguous region of a source file that corresponds to a
  /// particular [BlobNode].
  ///
  /// The range does not contain the end.
  final SourceLocation end;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != SourceRange) {
      return false;
    }
    return other is SourceRange
        && start == other.start
        && end == other.end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() {
    return '${start.source}@${start.offset}..${end.offset}';
  }
}

/// Base class of nodes that appear in the output of [decodeDataBlob] and
/// [decodeLibraryBlob].
///
/// In addition to this, the following types can be found in that output:
///
///  * [DynamicMap]
///  * [DynamicList]
///  * [int]
///  * [double]
///  * [bool]
///  * [String]
abstract class BlobNode {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const BlobNode();

  // We use an [Expando] so that there is no (or minimal) overhead in production
  // environments that don't need to track source locations. It would be cleaner
  // to store the information directly on the [BlobNode], as then we could enforce
  // that that information is always propagated, instead of relying on remembering
  // to do so. However, that would require growing the size of every [BlobNode]
  // object, and would require additional logic even in the binary parser (which
  // does not track source locations currently).
  static final Expando<SourceRange> _sources = Expando<SourceRange>('BlobNode._sources');

  /// The source location that corresponds to this [BlobNode], if known.
  ///
  /// In normal use, this returns null. However, if source location tracking is
  /// enabled (e.g. by specifying the `sourceIdentifier` argument to
  /// [parseLibraryFile]), then this will return the range of the source file
  /// that corresponds to this [BlobNode].
  ///
  /// A [BlobNode] can also be manually associated with a given [SourceRange]
  /// using [associateSource] or [propagateSource].
  SourceRange? get source {
    return _sources[this];
  }

  /// Assign a [SourceRange] to this [BlobNode]'s [source] property.
  ///
  /// Typically, this is used exclusively by the parser (notably,
  /// [parseLibraryFile]).
  ///
  /// Tracking source location information introduces a memory overhead and
  /// should therefore only be used when necessary (e.g. for creating IDEs).
  ///
  /// Calling this method replaces any existing association.
  void associateSource(SourceRange source) {
    _sources[this] = source;
  }

  /// Assign another [BlobNode]'s [SourceRange] to this [BlobNode]'s [source]
  /// property.
  ///
  /// Typically, this is used exclusively by the [Runtime].
  ///
  /// If the `original` [BlobNode] is null or has no [source], then this has no
  /// effect. Otherwise, the [source] for this [BlobNode] is set to match that
  /// of the given `original` [BlobNode], replacing any existing association.
  void propagateSource(BlobNode? original) {
    if (original == null) {
      return;
    }
    final SourceRange? source = _sources[original];
    if (source != null) {
      _sources[this] = source;
    }
  }
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null || a.length != b.length) {
    return false;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

/// The name of a widgets library in the RFW package.
///
/// Libraries are typically referred to with names like "core.widgets" or
/// "com.example.shopping.cart". This class represents these names as lists of
/// tokens, in those cases `['core', 'widgets']` and `['com', 'example',
/// 'shopping', 'cart']`, for example.
@immutable
class LibraryName implements Comparable<LibraryName> {
  /// Wrap the given list as a [LibraryName].
  ///
  /// The given list is not copied; it is an error to modify it after creating
  /// the [LibraryName].
  const LibraryName(this.parts);

  /// The components of the structured library name.
  final List<String> parts;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LibraryName
        && _listEquals<String>(parts, other.parts);
  }

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() => parts.join('.');

  @override
  int compareTo(LibraryName other) {
    for (int index = 0; index < parts.length; index += 1) {
      if (other.parts.length <= index) {
        return 1;
      }
      final int result = parts[index].compareTo(other.parts[index]);
      if (result != 0) {
        return result;
      }
    }
    assert(other.parts.length >= parts.length);
    return parts.length - other.parts.length;
  }
}

/// The name of a widget used by the RFW package, including its library name.
///
/// This can be used to identify both local widgets and remote widgets.
@immutable
class FullyQualifiedWidgetName implements Comparable<FullyQualifiedWidgetName> {
  /// Wrap the given library name and widget name in a [FullyQualifiedWidgetName].
  const FullyQualifiedWidgetName(this.library, this.widget);

  /// The name of the library in which [widget] can be found.
  final LibraryName library;

  /// The name of the widget, which should be in the specified [library].
  final String widget;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is FullyQualifiedWidgetName
        && library == other.library && widget == other.widget;
  }

  @override
  int get hashCode => Object.hash(library, widget);

  @override
  String toString() => '$library:$widget';

  @override
  int compareTo(FullyQualifiedWidgetName other) {
    final int result = library.compareTo(other.library);
    if (result != 0) {
      return result;
    }
    return widget.compareTo(other.widget);
  }
}

/// The type of the [missing] value.
///
/// This is used internally by the RFW package to avoid needing to use nullable
/// types.
class Missing extends BlobNode {
  const Missing._();

  @override
  String toString() => '<missing>';
}

/// The value used by [DynamicContent] to represent missing data.
///
/// This is return from [DynamicContent.subscribe] when the specified key is not
/// present.
///
/// Content in a [DynamicContent] should not contain [missing] values.
const Missing missing = Missing._();

/// Representation of the `...for` construct in Remote Flutter Widgets library
/// blobs.
class Loop extends BlobNode {
  /// Creates a [Loop] with the given [input] and [output].
  ///
  /// The provided objects must not be mutated after being given to the
  /// constructor (e.g. the ownership of any lists and maps passes to this
  /// object).
  const Loop(this.input, this.output);

  /// The list on which to iterate.
  ///
  /// This is typically some sort of [Reference], but could be a [DynamicList].
  ///
  /// It is an error for this to be a value that does not resolve to a list.
  final Object input;

  /// The template to apply for each value on [input].
  final Object output;

  @override
  String toString() => '...for loop in $input: $output';
}

/// Representation of the `switch` construct in Remote Flutter Widgets library
/// blobs.
class Switch extends BlobNode {
  /// Creates a [Switch] with the given [input] and [outputs].
  ///
  /// The provided objects must not be mutated after being given to the
  /// constructor. In particular, changing the [outputs] map after creating the
  /// [Switch] is an error.
  const Switch(this.input, this.outputs);

  /// The value to switch on. This is typically a reference, e.g. an
  /// [ArgsReference], which must be resolved by the runtime to determine the
  /// actual value on which to switch.
  final Object input;

  /// The cases for this switch. Keys correspond to values to compare with
  /// [input]. The null value is used as the default case.
  ///
  /// At runtime, if none of the keys match [input] and there is no null key,
  /// the [Switch] as a whole is treated as if it was [missing]. If the [Switch]
  /// is used where a [ConstructorCall] was expected, the result is an
  /// [ErrorWidget].
  final Map<Object?, Object> outputs;

  @override
  String toString() => 'switch $input $outputs';
}

/// Representation of references to widgets in Remote Flutter Widgets library
/// blobs.
class ConstructorCall extends BlobNode {
  /// Creates a [ConstructorCall] for a widget of the given name in the current
  /// library's scope, with the given [arguments].
  ///
  /// The [arguments] must not be mutated after the object is created.
  const ConstructorCall(this.name, this.arguments);

  /// The name of the widget to create.
  ///
  /// The name is looked up in the current library, or, failing that, in a
  /// depth-first search of this library's dependencies.
  final String name;

  /// The arguments to pass to the constructor.
  ///
  /// Constructors in RFW only have named arguments. This differs from Dart
  /// (where arguments can also be positional.)
  final DynamicMap arguments;

  @override
  String toString() => '$name($arguments)';
}

/// Representation of functions that return widgets in Remote Flutter Widgets library blobs.
class WidgetBuilderDeclaration extends BlobNode {
  /// Represents a callback that takes a single argument [argumentName] and returns the [widget].
  const WidgetBuilderDeclaration(this.argumentName, this.widget);

  /// The callback single argument name.
  ///
  /// In `Builder(builder: (scope) => Container());`, [argumentName] is "scope".
  final String argumentName;

  /// The widget that will be returned when the builder callback is called.
  ///
  /// This is usually a [ConstructorCall], but may be a [Switch] (so long as
  /// that [Switch] resolves to a [ConstructorCall]. Other values (or a [Switch]
  /// that does not resolve to a constructor call) will result in an
  /// [ErrorWidget] being used.
  final BlobNode widget;

  @override
  String toString() => '($argumentName) => $widget';
}

/// Base class for various kinds of references in the RFW data structures.
abstract class Reference extends BlobNode {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  ///
  /// The [parts] must not be mutated after the object is created.
  const Reference(this.parts);

  /// The components of the reference. Each entry must be either a String (to
  /// index into a [DynamicMap]) an integer (to index into a [DynamicList]).
  ///
  /// It is an error for any of the parts to be of any other type.
  final List<Object> parts;
}

/// Unbound reference to arguments.
///
/// This class is used to represent references of the form "args.foo.bar" after
/// parsing, before the arguments are bound.
class ArgsReference extends Reference {
  /// Wraps the given [parts] as an [ArgsReference].
  ///
  /// The [parts] must not be mutated after the object is created.
  const ArgsReference(super.parts);

  /// Binds the arguments reference to a specific set of arguments.
  ///
  /// Returns a [BoundArgsReference] with the same [parts] and whose
  /// [BoundArgsReference.arguments] is given by `arguments`.
  BoundArgsReference bind(Object arguments) {
    return BoundArgsReference(arguments, parts);
  }

  @override
  String toString() => 'args.${parts.join(".")}';
}

/// Bound reference to arguments.
///
/// This class is used to represent references of the form "args.foo.bar" after
/// a widget declaration has been bound to specific arguments via a constructor
/// call. The [arguments] property is a reference to the
/// [ConstructorCall.arguments] object (or, more typically, a clone of that
/// object that itself has had references within it bound).
///
/// This class is an internal detail of the RFW [Runtime] and is generally not
/// used directly.
class BoundArgsReference extends Reference {
  /// Wraps the given [parts] and [arguments] as a [BoundArgsReference].
  ///
  /// The parameters must not be mutated after the object is created.
  ///
  /// Generally this class is created using [ArgsReference.bind].
  const BoundArgsReference(this.arguments, List<Object> parts): super(parts);

  /// The object into which [parts] will be indexed.
  ///
  /// This could contain [Loop]s, which is why it cannot be indexed immediately
  /// upon creation.
  final Object arguments;

  @override
  String toString() => 'args($arguments).${parts.join(".")}';
}

/// Reference to the [DynamicContent] data that is passed into the widget (see
/// [Runtime.build]'s `data` argument).
class DataReference extends Reference {
  /// Wraps the given [parts] as a [DataReference].
  ///
  /// The [parts] must not be mutated after the object is created.
  const DataReference(super.parts);

  /// Creates a new [DataRefererence] that indexes even deeper than this one.
  ///
  /// For example, suppose a widget's arguments consisted of a map with one key,
  /// "a", whose value was a [DataRefererence] referencing "data.foo.bar". Now
  /// suppose that the widget itself has an [ArgsReference] that references
  /// "args.a.baz". The "args.a" part identifies the aforementioned
  /// [DataReference], and so the resulting reference is actually to
  /// "data.foo.bar.baz".
  ///
  /// In this example, the [DataReference] to "data.foo.bar" would have its
  /// [constructReference] method invoked by the runtime, with `["baz"]` as the
  /// `moreParts` argument, so that the resulting [DataReference]'s [parts] is a
  /// combination of the original's (`["foo", "bar"]`) and the additional parts
  /// provided to the method.
  DataReference constructReference(List<Object> moreParts) {
    return DataReference(parts + moreParts);
  }

  @override
  String toString() => 'data.${parts.join(".")}';
}

/// Reference to the single argument of type [DynamicMap] passed into the widget builder.
///
/// This class is used to represent references to a function argument.
/// In `(scope) => Container(width: scope.width)`, this represents "scope.width".
///
/// See also:
///
///   * [WidgetBuilderDeclaration], which represents a widget builder definition.
class WidgetBuilderArgReference extends Reference {
  /// Wraps the given [argumentName] and [parts] as a [WidgetBuilderArgReference].
  ///
  /// The parts must not be mutated after the object is created.
  const WidgetBuilderArgReference(this.argumentName, super.parts);

  /// A reference to a [WidgetBuilderDeclaration.argumentName].
  ///
  /// In `Builder(builder: (scope) => Text(text: scope.result.text));`,
  /// "scope.result.text" is the [WidgetBuilderArgReference].
  /// The [argumentName] is "scope" and its [parts] are `["result", "text"]`.
  final String argumentName;

  @override
  String toString() => '$argumentName.${parts.join('.')}';
}

/// Unbound reference to a [Loop].
class LoopReference extends Reference {
  /// Wraps the given [loop] and [parts] as a [LoopReference].
  ///
  /// The [parts] must not be mutated after the object is created.
  const LoopReference(this.loop, List<Object> parts): super(parts);

  /// The index to the referenced loop.
  ///
  /// Loop indices count up, so the nearest loop ancestor of the reference has
  /// index zero, with indices counting up when going up the tree towards the
  /// root.
  final int loop; // this is basically a De Bruijn index

  /// Creates a new [LoopRefererence] that indexes even deeper than this one.
  ///
  /// For example, suppose a widget's arguments consisted of a map with one key,
  /// "a", whose value was a [LoopRefererence] referencing "loop0.foo.bar". Now
  /// suppose that the widget itself has an [ArgsReference] that references
  /// "args.a.baz". The "args.a" part identifies the aforementioned
  /// [LoopReference], and so the resulting reference is actually to
  /// "loop0.foo.bar.baz".
  ///
  /// In this example, the [LoopReference] to "loop0.foo.bar" would have its
  /// [constructReference] method invoked by the runtime, with `["baz"]` as the
  /// `moreParts` argument, so that the resulting [LoopReference]'s [parts] is a
  /// combination of the original's (`["foo", "bar"]`) and the additional parts
  /// provided to the method.
  ///
  /// The [loop] index is maintained in the new object.
  LoopReference constructReference(List<Object> moreParts) {
    return LoopReference(loop, parts + moreParts);
  }

  /// Binds the loop reference to a specific value.
  ///
  /// Returns a [BoundLoopReference] with the same [parts] and whose
  /// [BoundLoopReference.value] is given by `value`. The [loop] index is
  /// dropped in the process.
  BoundLoopReference bind(Object value) {
    return BoundLoopReference(value, parts);
  }

  @override
  String toString() => 'loop$loop.${parts.join(".")}';
}

/// Bound reference to a [Loop].
///
/// This class is used to represent references of the form "loopvar.foo.bar"
/// after the list containing the relevant loop has been dereferenced so that
/// the loop variable refers to a specific value in the list. The [value] is
/// that resolved value.
///
/// This class is an internal detail of the RFW [Runtime] and is generally not
/// used directly.
class BoundLoopReference extends Reference {
  /// Wraps the given [value] and [parts] as a [BoundLoopReference].
  ///
  /// The [parts] must not be mutated after the object is created.
  ///
  /// Generally this class is created using [LoopReference.bind].
  const BoundLoopReference(this.value, List<Object> parts): super(parts);

  /// The object into which [parts] will index.
  ///
  /// This could contain further [Loop]s or unbound [LoopReference]s, which is
  /// why it cannot be indexed immediately upon creation.
  final Object value;

  /// Creates a new [BoundLoopRefererence] that indexes even deeper than this
  /// one.
  ///
  /// For example, suppose a widget's arguments consisted of a map with one key,
  /// "a", whose value was a [BoundLoopRefererence] referencing "loop0.foo.bar".
  /// Now suppose that the widget itself has an [ArgsReference] that references
  /// "args.a.baz". The "args.a" part identifies the aforementioned
  /// [BoundLoopReference], and so the resulting reference is actually to
  /// "loop0.foo.bar.baz".
  ///
  /// In this example, the [BoundLoopReference] to "loop0.foo.bar" would have
  /// its [constructReference] method invoked by the runtime, with `["baz"]` as
  /// the `moreParts` argument, so that the resulting [BoundLoopReference]'s
  /// [parts] is a combination of the original's (`["foo", "bar"]`) and the
  /// additional parts provided to the method.
  ///
  /// The resolved [value] (which is what the [parts] will eventually index
  /// into) is maintained in the new object.
  BoundLoopReference constructReference(List<Object> moreParts) {
    return BoundLoopReference(value, parts + moreParts);
  }

  @override
  String toString() => 'loop($value).${parts.join(".")}';
}

/// Base class for [StateReference] and [BoundStateReference].
///
/// This is used to ensure [SetStateHandler]'s [SetStateHandler.stateReference]
/// property can only hold a state reference.
abstract class AnyStateReference extends Reference {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  ///
  /// The [parts] must not be mutated after the object is created.
  const AnyStateReference(super.parts);
}

/// Unbound reference to remote widget's state.
///
/// This class is used to represent references of the form "state.foo.bar".
class StateReference extends AnyStateReference {
  /// Wraps the given [parts] as a [StateReference].
  ///
  /// The [parts] must not be mutated after the object is created.
  const StateReference(super.parts);

  /// Binds the state reference to a specific widget (identified by depth).
  ///
  /// Returns a [BoundStateReference] with the same [parts] and whose
  /// [BoundLoopReference.depth] is given by `depth`.
  BoundStateReference bind(int depth) {
    return BoundStateReference(depth, parts);
  }

  @override
  String toString() => 'state.${parts.join(".")}';
}

/// Bound reference to a remote widget's state.
///
/// This class is used to represent references of the form "state.foo.bar" after
/// the widgets have been constructed, so that the right state can be
/// identified.
///
/// This class is an internal detail of the RFW [Runtime] and is generally not
/// used directly.
class BoundStateReference extends AnyStateReference {
  /// Wraps the given [depth] and [parts] as a [BoundStateReference].
  ///
  /// The [parts] must not be mutated after the object is created.
  ///
  /// Generally this class is created using [StateReference.bind].
  const BoundStateReference(this.depth, List<Object> parts): super(parts);

  /// The widget to whose state the state reference refers.
  ///
  /// This identifies the widget by depth starting at the widget that was
  /// created by [Runtime.build] (or a [RemoteWidget], which uses that method).
  ///
  /// Since state references always go up the tree, this is an unambiguous way
  /// to reference state, even though in practice in the entire tree multiple
  /// widgets may be stateful at the same depth.
  final int depth;

  /// Creates a new [BoundStateRefererence] that indexes even deeper than this
  /// one (deeper into the specified widget's state, not into a deeper widget!).
  ///
  /// For example, suppose a widget's arguments consisted of a map with one key,
  /// "a", whose value was a [BoundStateRefererence] referencing "state.foo.bar".
  /// Now suppose that the widget itself has an [ArgsReference] that references
  /// "args.a.baz". The "args.a" part identifies the aforementioned
  /// [BoundStateReference], and so the resulting reference is actually to
  /// "state.foo.bar.baz".
  ///
  /// In this example, the [BoundStateReference] to "state.foo.bar" would have
  /// its [constructReference] method invoked by the runtime, with `["baz"]` as
  /// the `moreParts` argument, so that the resulting [BoundStateReference]'s
  /// [parts] is a combination of the original's (`["foo", "bar"]`) and the
  /// additional parts provided to the method.
  ///
  /// The [depth] is maintained in the new object.
  BoundStateReference constructReference(List<Object> moreParts) {
    return BoundStateReference(depth, parts + moreParts);
  }

  @override
  String toString() => 'state^$depth.${parts.join(".")}';
}

/// Base class for [EventHandler] and [SetStateHandler].
///
/// This is used by the [Runtime] to quickly filter out objects that are not
/// event handlers of any kind.
abstract class AnyEventHandler extends BlobNode {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const AnyEventHandler();
}

/// Description of a callback in an RFW widget declaration.
///
/// This represents a signal to send to the application using the RFW package.
/// Typically applications either handle such messages locally, or forward them
/// to a server for further processing.
class EventHandler extends AnyEventHandler {
  /// Wraps the given event name and arguments in an [EventHandler] object.
  ///
  /// The [eventArguments] must not be mutated after the object is created.
  const EventHandler(this.eventName, this.eventArguments);

  /// A string to identify the event. This provides an unambiguous identifier
  /// for the event, avoiding the need to establish a convention in the
  /// [eventArguments].
  final String eventName;

  /// The payload to provide with the event.
  final DynamicMap eventArguments;

  @override
  String toString() => 'event $eventName $eventArguments';
}

/// Description of a state setter in an RFW widget declaration.
///
/// This event handler is handled by the RFW [Runtime] itself by setting the
/// state referenced by [stateReference] to the value represented by [value]
/// when the event handler would be invoked.
class SetStateHandler extends AnyEventHandler {
  /// Wraps the given [stateReference] and [value] in a [SetStateHandler] object.
  ///
  /// The [value] must not be mutated after the object is created (e.g. in the
  /// event that it is a [DynamicMap] or [DynamicList]).
  const SetStateHandler(this.stateReference, this.value);

  /// Identifies the member in the widget's state to mutate.
  final AnyStateReference stateReference;

  /// The value to which the specified state will be set.
  final Object value;

  @override
  String toString() => 'set $stateReference = $value';
}

/// A library import.
///
/// Used to describe which libraries a remote widget libraries depends on. The
/// identified libraries can be local or remote. Import loops are invalid.
// TODO(ianh): eventually people will probably want a way to disambiguate imports
// with a prefix.
class Import extends BlobNode {
  /// Wraps the given library [name] in an [Import] object.
  const Import(this.name);

  /// The name of the library to import.
  final LibraryName name;

  @override
  String toString() => 'import $name;';
}

/// A description of a widget in a remote widget library.
///
/// The [root] must be either a [ConstructorCall] or a [Switch] that evaluates
/// to a [ConstructorCall]. (In principle one can imagine that an
/// [ArgsReference] that evaluates to a [ConstructorCall] would also be valid,
/// but such a construct would be redundant and would not provide any additional
/// expressivity, so it is disallowed.)
///
/// The tree rooted at [root] must not contain (directly or indirectly) a
/// [ConstructorCall] that references the widget declared by this
/// [WidgetDeclaration]: widget loops, even indirect loops or loops that would
/// in principle be terminated by use of a [Switch], are not allowed.
class WidgetDeclaration extends BlobNode {
  /// Binds the given [name] to the definition given by [root].
  ///
  /// The [initialState] may be null. If it is not, this represents a stateful widget.
  const WidgetDeclaration(this.name, this.initialState, this.root) : assert(root is ConstructorCall || root is Switch);

  /// The name of the widget that this declaration represents.
  ///
  /// This is the left hand side of a widget declaration.
  final String name;

  /// If non-null, this is a stateful widget; the value is used to create the
  /// initial copy of the state when the widget is created.
  final DynamicMap? initialState;

  /// The widget to return when this widget is used.
  ///
  /// This is usually a [ConstructorCall], but may be a [Switch] (so long as
  /// that [Switch] resolves to a [ConstructorCall]. Other values (or a [Switch]
  /// that does not resolve to a constructor call) will result in an
  /// [ErrorWidget] being used.
  final BlobNode root; // ConstructorCall or Switch

  @override
  String toString() => 'widget $name = $root;';
}

/// Base class for widget libraries.
abstract class WidgetLibrary {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const WidgetLibrary();
}

/// The in-memory representation of the output of [parseTextLibraryFile] or
/// [decodeLibraryBlob].
class RemoteWidgetLibrary extends WidgetLibrary {
  /// Wraps a set of [imports] and [widgets] (widget declarations) in a
  /// [RemoteWidgetLibrary] object.
  ///
  /// The provided lists must not be mutated once the library is created.
  const RemoteWidgetLibrary(this.imports, this.widgets);

  /// The list of libraries that this library depends on.
  ///
  /// This must not be empty, since at least one local widget library must be in
  /// scope in order for the remote widget library to be useful.
  final List<Import> imports;

  /// The list of widgets declared by this library.
  ///
  /// This can be empty.
  final List<WidgetDeclaration> widgets;

  @override
  String toString() => const Iterable<Object>.empty().followedBy(imports).followedBy(widgets).join('\n');
}
