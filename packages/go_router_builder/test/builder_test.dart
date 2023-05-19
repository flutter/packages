// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router_builder/src/go_router_generator.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:source_gen_test/source_gen_test.dart';

Future<void> main() async {
  initializeBuildLogTracking();
  final LibraryReader testReader = await initializeLibraryReaderForDirectory(
    p.join('test', 'test_inputs'),
    '_go_router_builder_test_input.dart',
  );

  testAnnotatedElements(
    testReader,
    const GoRouterGenerator(),
    expectedAnnotatedTests: _expectedAnnotatedTests,
  );
}

const Set<String> _expectedAnnotatedTests = <String>{
  'AppliedToWrongClassType',
  'BadPathParam',
  'ExtraValueRoute',
  'RequiredExtraValueRoute',
  'MissingPathValue',
  'MissingTypeAnnotation',
  'NullableRequiredParamInPath',
  'NullableRequiredParamNotInPath',
  'NonNullableRequiredParamNotInPath',
  'UnsupportedType',
  'theAnswer',
  'EnumParam',
  'DefaultValueRoute',
  'NullableDefaultValueRoute',
  'IterableWithEnumRoute',
  'IterableDefaultValueRoute',
  'NamedRoute',
  'NamedEscapedRoute',
};
