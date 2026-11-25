// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "v4l2_system.h"

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <unistd.h>

#include <cstdlib>

namespace camera_linux_v4l2 {
namespace {

constexpr char kDevDirectory[] = "/dev/";
constexpr char kVideoDevicePrefix[] = "/dev/video";

// Bounds the work done for a /dev that contains an unusual number of nodes.
constexpr int kMaxVideoNodes = 64;

int VideoNodeFilter(const struct dirent* entry) {
  return IsVideoDevicePath(std::string(kDevDirectory) + entry->d_name) ? 1 : 0;
}

}  // namespace

bool IsVideoDevicePath(const std::string& path) {
  const size_t prefix_length = sizeof(kVideoDevicePrefix) - 1;
  return path.size() > prefix_length &&
         path.compare(0, prefix_length, kVideoDevicePrefix) == 0 &&
         path.find_first_not_of("0123456789", prefix_length) ==
             std::string::npos;
}

std::vector<std::string> PosixV4l2System::ListVideoDevices() {
  std::vector<std::string> paths;
  struct dirent** entries = nullptr;
  // versionsort orders video2 before video10.
  const int count =
      scandir(kDevDirectory, &entries, VideoNodeFilter, versionsort);
  for (int i = 0; i < count; ++i) {
    if (i < kMaxVideoNodes) {
      paths.push_back(std::string(kDevDirectory) + entries[i]->d_name);
    }
    free(entries[i]);
  }
  free(entries);
  return paths;
}

int PosixV4l2System::Open(const char* path, int flags) {
  return open(path, flags);
}

int PosixV4l2System::Close(int fd) { return close(fd); }

int PosixV4l2System::Ioctl(int fd, unsigned long request, void* arg) {
  int r;
  do {
    r = ioctl(fd, request, arg);
  } while (r == -1 && errno == EINTR);
  return r;
}

void* PosixV4l2System::Mmap(void* addr, size_t length, int prot, int flags,
                            int fd, off_t offset) {
  return mmap(addr, length, prot, flags, fd, offset);
}

int PosixV4l2System::Munmap(void* addr, size_t length) {
  return munmap(addr, length);
}

int PosixV4l2System::Poll(struct pollfd* fds, nfds_t nfds, int timeout_ms) {
  return poll(fds, nfds, timeout_ms);
}

}  // namespace camera_linux_v4l2
