// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

library mdns.src.native_extension_api;

import 'dart:isolate';

import "dart-ext:../mdns_extension_lib";

SendPort servicePort() native 'MDnsExtension_ServicePort';
