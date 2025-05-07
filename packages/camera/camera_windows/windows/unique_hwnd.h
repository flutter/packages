// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_UNIQUE_HWND_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_UNIQUE_HWND_H_

#include <windows.h>

#include <memory>

namespace camera_windows {

struct UniqueHWNDDeleter {
  typedef HWND pointer;

  void operator()(HWND hwnd) {
    if (hwnd) {
      DestroyWindow(hwnd);
    }
  }
};

typedef std::unique_ptr<HWND, UniqueHWNDDeleter> UniqueHWND;

}  // namespace camera_windows

#endif PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_UNIQUE_HWND_H_
