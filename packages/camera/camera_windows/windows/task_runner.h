// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TASK_RUNNER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TASK_RUNNER_H_

#include <functional>

namespace camera_windows {

/// A closure that can be run as a task.
using TaskClosure = std::function<void()>;

/// A task queue for scheduling functions to be executed in a different thread.
class TaskRunner {
 public:
  /// Schedule a function/closure to be executed as soon as possible.
  virtual void EnqueueTask(TaskClosure task) = 0;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_TASK_RUNNER_H_
