// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This constant holds the base64-encoded data of a 16x16 PNG image of the
/// Flutter logo.
///
/// See `icon_image.png` source in the same directory.
///
/// To create or update this image, follow these steps:
/// 1. Create or update a 16x16 PNG image.
/// 2. Convert the image to a base64 string using a script below.
/// 3. Replace the existing base64 string below with the new one.
///
/// Example of converting an image to base64 in Dart:
/// ```dart
/// import 'dart:convert';
/// import 'dart:io';
///
/// void main() async {
///   final bytes = await File('icon_image.png').readAsBytes();
///   final base64String = base64Encode(bytes);
///   print(base64String);
/// }
/// ```
const String iconImageBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAIRlWElmTU'
    '0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIA'
    'AIdpAAQAAAABAAAAWgAAAAAAAABIAAAAAQAAAEgAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQ'
    'AAABCgAwAEAAAAAQAAABAAAAAAx28c8QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1M'
    'OmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIH'
    'g6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8v'
    'd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcm'
    'lwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFk'
    'b2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk'
    '9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6'
    'eG1wbWV0YT4KTMInWQAAAplJREFUOBF1k01ME1EQx2fe7tIPoGgTE6AJgQQSPaiH9oAtkFbsgX'
    'jygFcT0XjSkxcTDxtPJh6MR28ePMHBBA8cNLSIony0oBhEMVETP058tE132+7uG3cW24DAXN57'
    '2fn9/zPz3iIcEdEl0nIxtNLr1IlVeoMadkubKmoL+u2SzAV8IjV5Ekt4GN+A8+VOUPwLarOI2G'
    'Vpqq0i4JQorwQxPtWHVZ1IKP8LNGDXGaSyqARFxDGo7MJBy4XVf3AyQ+qTHnTEXoF9cFUy3OkY'
    '0oWxmWFtD5xNoc1sQ6AOn1+hCNTkkhKow8KFZV77tVs2O9dhFvBm0IA/U0RhZ7/ocEx23oUDlh'
    'h8HkNjZIN8Lb3gOU8gOp7AKJHCB2/aNZkTftHumNzzbtl2CBPZHqxw8mHhVZBeoz6w5DvhE2FZ'
    'lQYPjKdd2/qRyKZ6KsPv7TEk7EYEk0A0EUmJduHRy1i4oLKqgmC59ZggAdwrC9pFuWy1iUT2rA'
    'uv0h2UdNtNqxCBBkgqorjOMOgksN7CxQ90vEb00U3c3LIwyo9o8FXxQVNr8Coqyk+S5EPBXnjt'
    'xRmc4TegI7qWbvBkeeUbGMnTCd4nZnYeDOWIEtlC6cKK/JJepY3hZSvN33jovO6L0XFqPKqBTO'
    'FuapUoPr1lxDM7cmC2TAOz25cYSGa++feBew/cjpc0V+mNT29/HZp3KDFTNLvuTRPEHy5065lj'
    'Xn4y41XM+wP/AlcycRmdc3MUhvLm/J/ceu/3qUVT62oP2EZpjSylHybHSpDUVcjq9gEBVo0+Xt'
    'JyN2IWRO+3QUforRoKnZLVsglaMECW+YmMSj9M3SrC6Lg71CMiqWfUrJ6ywzefhnZ+G69BaKdB'
    'WhXQAn6wzDUpfUPw7MrmX/WhbfmKblw+AAAAAElFTkSuQmCC';
