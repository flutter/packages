// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_V4L2_SYSTEM_H_
#define PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_V4L2_SYSTEM_H_

#include <poll.h>
#include <sys/types.h>

#include <cstddef>
#include <string>
#include <vector>

namespace camera_linux_v4l2 {

// Returns whether `path` has the form "/dev/video<N>", the only kind of path
// this plugin lists or opens.
bool IsVideoDevicePath(const std::string& path);

// Abstraction over V4L2 / POSIX device syscalls so capture and enumeration
// logic can be unit tested without hardware.
class V4l2System {
 public:
  virtual ~V4l2System() = default;

  // Returns the /dev/video<N> paths that exist, in ascending order of N.
  virtual std::vector<std::string> ListVideoDevices() = 0;
  virtual int Open(const char* path, int flags) = 0;
  virtual int Close(int fd) = 0;
  virtual int Ioctl(int fd, unsigned long request, void* arg) = 0;
  virtual void* Mmap(void* addr, size_t length, int prot, int flags, int fd,
                     off_t offset) = 0;
  virtual int Munmap(void* addr, size_t length) = 0;
  virtual int Poll(struct pollfd* fds, nfds_t nfds, int timeout_ms) = 0;
};

// Production V4l2System delegating to POSIX and /dev.
class PosixV4l2System final : public V4l2System {
 public:
  std::vector<std::string> ListVideoDevices() override;
  int Open(const char* path, int flags) override;
  int Close(int fd) override;
  int Ioctl(int fd, unsigned long request, void* arg) override;
  void* Mmap(void* addr, size_t length, int prot, int flags, int fd,
             off_t offset) override;
  int Munmap(void* addr, size_t length) override;
  int Poll(struct pollfd* fds, nfds_t nfds, int timeout_ms) override;
};

}  // namespace camera_linux_v4l2

#endif  // PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_V4L2_SYSTEM_H_
