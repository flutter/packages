// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "task_runner_window.h"

#include <algorithm>
#include <iostream>

namespace camera_windows {

TaskRunnerWindow::TaskRunnerWindow() {
  WNDCLASS window_class = RegisterWindowClass();
  window_handle_.reset(CreateWindowEx(0, window_class.lpszClassName, L"", 0, 0,
                                      0, 0, 0, HWND_MESSAGE, nullptr,
                                      window_class.hInstance, nullptr));

  if (window_handle_) {
    SetWindowLongPtr(window_handle_.get(), GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(this));
  } else {
    auto error = GetLastError();
    LPWSTR message = nullptr;
    FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM |
                       FORMAT_MESSAGE_IGNORE_INSERTS,
                   NULL, error, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                   reinterpret_cast<LPWSTR>(&message), 0, NULL);
    OutputDebugString(message);
    LocalFree(message);
  }
}

TaskRunnerWindow::~TaskRunnerWindow() {
  UnregisterClass(window_class_name_.c_str(), nullptr);
}

void TaskRunnerWindow::EnqueueTask(TaskClosure task) {
  {
    std::lock_guard<std::mutex> lock(tasks_mutex_);
    tasks_.push(task);
  }
  if (!PostMessage(window_handle_.get(), WM_NULL, 0, 0)) {
    DWORD error_code = GetLastError();
    std::cerr << "Failed to post message to main thread; error_code: "
              << error_code << std::endl;
  }
}

void TaskRunnerWindow::ProcessTasks() {
  // Even though it would usually be sufficient to process only a single task
  // whenever a message is received, if the message queue happens to be full,
  // there may have been fewer messages received than tasks in the queue.
  for (;;) {
    TaskClosure task;
    {
      std::lock_guard<std::mutex> lock(tasks_mutex_);
      if (tasks_.empty()) break;
      task = tasks_.front();
      tasks_.pop();
    }
    task();
  }
}

WNDCLASS TaskRunnerWindow::RegisterWindowClass() {
  window_class_name_ = L"FlutterPluginCameraWindowsTaskRunnerWindow";

  WNDCLASS window_class{};
  window_class.hCursor = nullptr;
  window_class.lpszClassName = window_class_name_.c_str();
  window_class.style = 0;
  window_class.cbClsExtra = 0;
  window_class.cbWndExtra = 0;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.hIcon = nullptr;
  window_class.hbrBackground = 0;
  window_class.lpszMenuName = nullptr;
  window_class.lpfnWndProc = WndProc;
  RegisterClass(&window_class);
  return window_class;
}

LRESULT
TaskRunnerWindow::HandleMessage(UINT const message, WPARAM const wparam,
                                LPARAM const lparam) noexcept {
  switch (message) {
    case WM_NULL:
      ProcessTasks();
      return 0;
  }
  return DefWindowProcW(window_handle_.get(), message, wparam, lparam);
}

LRESULT TaskRunnerWindow::WndProc(HWND const window, UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept {
  if (auto* that = reinterpret_cast<TaskRunnerWindow*>(
          GetWindowLongPtr(window, GWLP_USERDATA))) {
    return that->HandleMessage(message, wparam, lparam);
  } else {
    return DefWindowProc(window, message, wparam, lparam);
  }
}

}  // namespace camera_windows
