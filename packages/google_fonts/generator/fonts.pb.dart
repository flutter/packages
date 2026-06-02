// This is a generated file - do not edit.
//
// Generated from generator/fonts.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Details required for a checked download
/// A Downloadable Font will typically have a hash but no filename.
/// A System Font will typically have only a filename.
/// Hash is 20 bytes sha1 up to v12, 32 byte sha256 for v13+,
class FileSpec extends $pb.GeneratedMessage {
  factory FileSpec({
    $core.String? filename,
    $fixnum.Int64? fileSize,
    $core.List<$core.int>? hash,
  }) {
    final result = create();
    if (filename != null) result.filename = filename;
    if (fileSize != null) result.fileSize = fileSize;
    if (hash != null) result.hash = hash;
    return result;
  }

  FileSpec._();

  factory FileSpec.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileSpec.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileSpec',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'fonts'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..aInt64(2, _omitFieldNames ? '' : 'fileSize')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'hash', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileSpec clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileSpec copyWith(void Function(FileSpec) updates) =>
      super.copyWith((message) => updates(message as FileSpec)) as FileSpec;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileSpec create() => FileSpec._();
  @$core.override
  FileSpec createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileSpec getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileSpec>(create);
  static FileSpec? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get fileSize => $_getI64(1);
  @$pb.TagNumber(2)
  set fileSize($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get hash => $_getN(2);
  @$pb.TagNumber(3)
  set hash($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearHash() => $_clearField(3);
}

/// To allow expression of variation font capability, e.g. weight 300-700
class IntRange extends $pb.GeneratedMessage {
  factory IntRange({
    $core.int? start,
    $core.int? end,
  }) {
    final result = create();
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    return result;
  }

  IntRange._();

  factory IntRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IntRange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IntRange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'fonts'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'start')
    ..aI(2, _omitFieldNames ? '' : 'end')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntRange copyWith(void Function(IntRange) updates) =>
      super.copyWith((message) => updates(message as IntRange)) as IntRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IntRange create() => IntRange._();
  @$core.override
  IntRange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IntRange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IntRange>(create);
  static IntRange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get start => $_getIZ(0);
  @$pb.TagNumber(1)
  set start($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearStart() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get end => $_getIZ(1);
  @$pb.TagNumber(2)
  set end($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => $_clearField(2);
}

/// To allow expression of variation font capability, e.g. weight 300-700
/// If end is <= start it's a point (e.g. for a non-variational font).
/// Where possible prefer end = 0 for point to save the field in binary proto.
class FloatRange extends $pb.GeneratedMessage {
  factory FloatRange({
    $core.double? start,
    $core.double? end,
  }) {
    final result = create();
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    return result;
  }

  FloatRange._();

  factory FloatRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FloatRange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FloatRange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'fonts'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'start', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'end', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FloatRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FloatRange copyWith(void Function(FloatRange) updates) =>
      super.copyWith((message) => updates(message as FloatRange)) as FloatRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FloatRange create() => FloatRange._();
  @$core.override
  FloatRange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FloatRange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FloatRange>(create);
  static FloatRange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get start => $_getN(0);
  @$pb.TagNumber(1)
  set start($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearStart() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get end => $_getN(1);
  @$pb.TagNumber(2)
  set end($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => $_clearField(2);
}

/// Describes a single optentype font file, which may be a variation font or a
/// single font from a TTC.
class Font extends $pb.GeneratedMessage {
  factory Font({
    FileSpec? file,
    IntRange? weight,
    FloatRange? width,
    FloatRange? italic,
    $core.int? ttcIndex,
    $core.String? postScriptName,
    $core.bool? isVf,
  }) {
    final result = create();
    if (file != null) result.file = file;
    if (weight != null) result.weight = weight;
    if (width != null) result.width = width;
    if (italic != null) result.italic = italic;
    if (ttcIndex != null) result.ttcIndex = ttcIndex;
    if (postScriptName != null) result.postScriptName = postScriptName;
    if (isVf != null) result.isVf = isVf;
    return result;
  }

  Font._();

  factory Font.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Font.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Font',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'fonts'),
      createEmptyInstance: create)
    ..aOM<FileSpec>(1, _omitFieldNames ? '' : 'file',
        subBuilder: FileSpec.create)
    ..aOM<IntRange>(2, _omitFieldNames ? '' : 'weight',
        subBuilder: IntRange.create)
    ..aOM<FloatRange>(3, _omitFieldNames ? '' : 'width',
        subBuilder: FloatRange.create)
    ..aOM<FloatRange>(4, _omitFieldNames ? '' : 'italic',
        subBuilder: FloatRange.create)
    ..aI(7, _omitFieldNames ? '' : 'ttcIndex')
    ..aOS(8, _omitFieldNames ? '' : 'postScriptName')
    ..aOB(9, _omitFieldNames ? '' : 'isVf')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Font clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Font copyWith(void Function(Font) updates) =>
      super.copyWith((message) => updates(message as Font)) as Font;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Font create() => Font._();
  @$core.override
  Font createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Font getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Font>(create);
  static Font? _defaultInstance;

  @$pb.TagNumber(1)
  FileSpec get file => $_getN(0);
  @$pb.TagNumber(1)
  set file(FileSpec value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => $_clearField(1);
  @$pb.TagNumber(1)
  FileSpec ensureFile() => $_ensure(0);

  /// numeric weight per https://drafts.csswg.org/css-fonts/#propdef-font-weight
  /// if varfont, range of 'wght' per
  /// https://www.microsoft.com/typography/otspec/fvar.htm#VAT
  @$pb.TagNumber(2)
  IntRange get weight => $_getN(1);
  @$pb.TagNumber(2)
  set weight(IntRange value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasWeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeight() => $_clearField(2);
  @$pb.TagNumber(2)
  IntRange ensureWeight() => $_ensure(1);

  /// names converted to values per
  /// https://www.microsoft.com/typography/otspec/os2.htm#wdc
  /// if varfont, range of 'wdth' per
  /// https://www.microsoft.com/typography/otspec/fvar.htm#VAT
  @$pb.TagNumber(3)
  FloatRange get width => $_getN(2);
  @$pb.TagNumber(3)
  set width(FloatRange value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);
  @$pb.TagNumber(3)
  FloatRange ensureWidth() => $_ensure(2);

  /// 0.0 or 1.0 per https://www.microsoft.com/typography/otspec/os2.htm#fss
  /// bit 0. if varfont, range of 'ital' per
  /// https://www.microsoft.com/typography/otspec/fvar.htm#VAT
  @$pb.TagNumber(4)
  FloatRange get italic => $_getN(3);
  @$pb.TagNumber(4)
  set italic(FloatRange value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasItalic() => $_has(3);
  @$pb.TagNumber(4)
  void clearItalic() => $_clearField(4);
  @$pb.TagNumber(4)
  FloatRange ensureItalic() => $_ensure(3);

  /// Google Fonts doesn't have any [yet?] but Android does
  @$pb.TagNumber(7)
  $core.int get ttcIndex => $_getIZ(4);
  @$pb.TagNumber(7)
  set ttcIndex($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(7)
  $core.bool hasTtcIndex() => $_has(4);
  @$pb.TagNumber(7)
  void clearTtcIndex() => $_clearField(7);

  /// Used for matching against system fonts.
  @$pb.TagNumber(8)
  $core.String get postScriptName => $_getSZ(5);
  @$pb.TagNumber(8)
  set postScriptName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(8)
  $core.bool hasPostScriptName() => $_has(5);
  @$pb.TagNumber(8)
  void clearPostScriptName() => $_clearField(8);

  /// True if the font is a variable font.
  @$pb.TagNumber(9)
  $core.bool get isVf => $_getBF(6);
  @$pb.TagNumber(9)
  set isVf($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(9)
  $core.bool hasIsVf() => $_has(6);
  @$pb.TagNumber(9)
  void clearIsVf() => $_clearField(9);
}

class FontFamily extends $pb.GeneratedMessage {
  factory FontFamily({
    $core.String? name,
    $core.int? version,
    $core.Iterable<Font>? fonts,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (version != null) result.version = version;
    if (fonts != null) result.fonts.addAll(fonts);
    return result;
  }

  FontFamily._();

  factory FontFamily.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FontFamily.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FontFamily',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'fonts'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'version')
    ..pPM<Font>(4, _omitFieldNames ? '' : 'fonts', subBuilder: Font.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FontFamily clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FontFamily copyWith(void Function(FontFamily) updates) =>
      super.copyWith((message) => updates(message as FontFamily)) as FontFamily;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FontFamily create() => FontFamily._();
  @$core.override
  FontFamily createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FontFamily getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FontFamily>(create);
  static FontFamily? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get version => $_getIZ(1);
  @$pb.TagNumber(2)
  set version($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  /// Even for a variation font we may have several entries, for example Roboto
  /// as a varfont may
  /// span two files, one for regular and one for italic
  @$pb.TagNumber(4)
  $pb.PbList<Font> get fonts => $_getList(2);
}

/// A set of potentially available families.
class Directory extends $pb.GeneratedMessage {
  factory Directory({
    $core.Iterable<FontFamily>? family,
    $core.int? version,
    $core.String? description,
  }) {
    final result = create();
    if (family != null) result.family.addAll(family);
    if (version != null) result.version = version;
    if (description != null) result.description = description;
    return result;
  }

  Directory._();

  factory Directory.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Directory.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Directory',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'fonts'),
      createEmptyInstance: create)
    ..pPM<FontFamily>(1, _omitFieldNames ? '' : 'family',
        subBuilder: FontFamily.create)
    ..aI(5, _omitFieldNames ? '' : 'version')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Directory clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Directory copyWith(void Function(Directory) updates) =>
      super.copyWith((message) => updates(message as Directory)) as Directory;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Directory create() => Directory._();
  @$core.override
  Directory createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Directory getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Directory>(create);
  static Directory? _defaultInstance;

  /// sorted by name
  @$pb.TagNumber(1)
  $pb.PbList<FontFamily> get family => $_getList(0);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(1);
  @$pb.TagNumber(5)
  set version($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  /// Description of current directory version.
  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
