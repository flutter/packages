// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "task_runner_window.h"

#include <gtest/gtest.h>

#include <atomic>

namespace camera_windows {
namespace test {

static void ProcessOneMessage() {
  MSG msg;
  GetMessage(&msg, nullptr, 0, 0);
  TranslateMessage(&msg);
  DispatchMessage(&msg);
}

TEST(TaskRunnerWindow, EnqueuedTaskIsExecuted) {
  TaskRunnerWindow task_runner;

  volatile bool task_completed = false;

  task_runner.EnqueueTask([&task_completed]() { task_completed = true; });

  ProcessOneMessage();

  EXPECT_TRUE(task_completed);
}

}  // namespace test
}  // namespace camera_windows
