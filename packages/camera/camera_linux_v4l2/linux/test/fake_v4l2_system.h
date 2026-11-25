// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_TEST_FAKE_V4L2_SYSTEM_H_
#define PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_TEST_FAKE_V4L2_SYSTEM_H_

#include <errno.h>
#include <linux/videodev2.h>
#include <poll.h>
#include <sys/mman.h>
#include <unistd.h>

#include <algorithm>
#include <cstring>
#include <deque>
#include <limits>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

#include "v4l2_system.h"

namespace camera_linux_v4l2 {
namespace test {

// Configurable fake V4L2 device backed by a real OS pipe so poll() in
// CameraSession wakes up deterministically without timing hacks.
struct FakeV4l2Device {
  std::string path;
  uint32_t capabilities =
      V4L2_CAP_VIDEO_CAPTURE | V4L2_CAP_STREAMING | V4L2_CAP_DEVICE_CAPS;
  uint32_t device_caps = V4L2_CAP_VIDEO_CAPTURE | V4L2_CAP_STREAMING;
  std::vector<uint32_t> formats = {V4L2_PIX_FMT_YUYV};

  uint32_t negotiated_width = 0;   // 0 = echo requested width
  uint32_t negotiated_height = 0;  // 0 = echo requested height
  uint32_t negotiated_fourcc = 0;  // 0 = echo requested fourcc
  uint32_t negotiated_bytes_per_line = 0;
  uint32_t granted_buffers = 4;
  size_t mapped_buffer_length = 0;

  int open_errno = 0;
  bool fail_querycap = false;
  bool fail_s_fmt = false;
  bool fail_reqbufs = false;
  bool fail_querybuf = false;
  bool fail_mmap = false;
  bool fail_qbuf = false;
  bool fail_streamon = false;
  int dqbuf_errno = 0;
  bool flag_frames_as_corrupt = false;
  bool endless_formats = false;  // VIDIOC_ENUM_FMT never reports the end.
  int stream_qbuf_errno = 0;

  std::mutex mutex;
  int read_fd = -1;
  int write_fd = -1;
  bool streaming = false;
  int open_count = 0;
  int enum_fmt_count = 0;
  int close_count = 0;
  int mmap_count = 0;
  int munmap_count = 0;
  uint32_t next_index = 0;
  std::vector<std::vector<uint8_t>> mapped_buffers;
  std::deque<std::vector<uint8_t>> pending_frames;

  void PushFrame(std::vector<uint8_t> bytes) {
    std::lock_guard<std::mutex> lock(mutex);
    pending_frames.push_back(std::move(bytes));
    if (write_fd >= 0) {
      const uint8_t signal = 1;
      std::ignore = write(write_fd, &signal, 1);
    }
  }

  void Disconnect() {
    std::lock_guard<std::mutex> lock(mutex);
    if (write_fd >= 0) {
      close(write_fd);
      write_fd = -1;
    }
  }
};

class FakeV4l2System final : public V4l2System {
 public:
  FakeV4l2Device* AddDevice(std::string path) {
    auto dev = std::unique_ptr<FakeV4l2Device>(new FakeV4l2Device());
    dev->path = std::move(path);
    FakeV4l2Device* ptr = dev.get();
    device_order_.push_back(ptr->path);
    devices_[ptr->path] = std::move(dev);
    return ptr;
  }

  FakeV4l2Device* GetDevice(const std::string& path) {
    auto it = devices_.find(path);
    return it == devices_.end() ? nullptr : it->second.get();
  }

  std::vector<std::string> ListVideoDevices() override { return device_order_; }

  int Open(const char* path, int flags) override {
    (void)flags;
    if (path == nullptr) {
      errno = EINVAL;
      return -1;
    }
    auto it = devices_.find(path);
    if (it == devices_.end()) {
      errno = ENOENT;
      return -1;
    }
    FakeV4l2Device* dev = it->second.get();
    if (dev->open_errno != 0) {
      errno = dev->open_errno;
      return -1;
    }
    int pipe_fds[2] = {-1, -1};
    if (pipe(pipe_fds) < 0) {
      return -1;
    }
    std::lock_guard<std::mutex> lock(dev->mutex);
    dev->read_fd = pipe_fds[0];
    dev->write_fd = pipe_fds[1];
    dev->open_count++;
    dev->next_index = 0;
    dev->streaming = false;
    open_fds_[dev->read_fd] = dev;
    return dev->read_fd;
  }

  int Close(int fd) override {
    auto it = open_fds_.find(fd);
    if (it == open_fds_.end()) {
      errno = EBADF;
      return -1;
    }
    FakeV4l2Device* dev = it->second;
    open_fds_.erase(it);
    std::lock_guard<std::mutex> lock(dev->mutex);
    if (dev->read_fd >= 0) {
      close(dev->read_fd);
      dev->read_fd = -1;
    }
    if (dev->write_fd >= 0) {
      close(dev->write_fd);
      dev->write_fd = -1;
    }
    dev->close_count++;
    return 0;
  }

  int Ioctl(int fd, unsigned long request, void* arg) override {
    auto it = open_fds_.find(fd);
    if (it == open_fds_.end()) {
      errno = EBADF;
      return -1;
    }
    FakeV4l2Device* dev = it->second;
    switch (request) {
      case VIDIOC_QUERYCAP: {
        if (dev->fail_querycap) {
          errno = ENOTTY;
          return -1;
        }
        auto* cap = static_cast<struct v4l2_capability*>(arg);
        std::memset(cap, 0, sizeof(*cap));
        cap->capabilities = dev->capabilities;
        cap->device_caps = dev->device_caps;
        return 0;
      }
      case VIDIOC_ENUM_FMT: {
        auto* desc = static_cast<struct v4l2_fmtdesc*>(arg);
        dev->enum_fmt_count++;
        if (dev->endless_formats) {
          desc->pixelformat = V4L2_PIX_FMT_MJPEG;
          return 0;
        }
        if (desc->index >= dev->formats.size()) {
          errno = EINVAL;
          return -1;
        }
        desc->pixelformat = dev->formats[desc->index];
        return 0;
      }
      case VIDIOC_S_FMT: {
        if (dev->fail_s_fmt) {
          errno = EINVAL;
          return -1;
        }
        auto* fmt = static_cast<struct v4l2_format*>(arg);
        if (dev->negotiated_width != 0) {
          fmt->fmt.pix.width = dev->negotiated_width;
        }
        if (dev->negotiated_height != 0) {
          fmt->fmt.pix.height = dev->negotiated_height;
        }
        if (dev->negotiated_fourcc != 0) {
          fmt->fmt.pix.pixelformat = dev->negotiated_fourcc;
        }
        fmt->fmt.pix.bytesperline = dev->negotiated_bytes_per_line;
        uint64_t min_stride = 0;
        switch (fmt->fmt.pix.pixelformat) {
          case V4L2_PIX_FMT_YUYV:
            min_stride =
                ((static_cast<uint64_t>(fmt->fmt.pix.width) + 1) / 2) * 4;
            break;
          case V4L2_PIX_FMT_RGB24:
          case V4L2_PIX_FMT_BGR24:
            min_stride = static_cast<uint64_t>(fmt->fmt.pix.width) * 3;
            break;
          default:
            min_stride = static_cast<uint64_t>(fmt->fmt.pix.width) * 4;
            break;
        }
        const uint64_t stride =
            std::max<uint64_t>(fmt->fmt.pix.bytesperline, min_stride);
        const uint64_t buffer_length = stride * fmt->fmt.pix.height;
        if (buffer_length == 0 ||
            buffer_length > std::numeric_limits<size_t>::max()) {
          errno = EOVERFLOW;
          return -1;
        }
        dev->mapped_buffer_length = static_cast<size_t>(buffer_length);
        return 0;
      }
      case VIDIOC_REQBUFS: {
        if (dev->fail_reqbufs) {
          errno = ENOMEM;
          return -1;
        }
        auto* req = static_cast<struct v4l2_requestbuffers*>(arg);
        req->count = dev->granted_buffers;
        std::lock_guard<std::mutex> lock(dev->mutex);
        dev->mapped_buffers.assign(
            dev->granted_buffers,
            std::vector<uint8_t>(dev->mapped_buffer_length, 0));
        return 0;
      }
      case VIDIOC_QUERYBUF: {
        if (dev->fail_querybuf) {
          errno = EINVAL;
          return -1;
        }
        auto* buf = static_cast<struct v4l2_buffer*>(arg);
        std::lock_guard<std::mutex> lock(dev->mutex);
        if (buf->index >= dev->mapped_buffers.size()) {
          errno = EINVAL;
          return -1;
        }
        buf->length =
            static_cast<uint32_t>(dev->mapped_buffers[buf->index].size());
        buf->m.offset = buf->index * 4096;
        return 0;
      }
      case VIDIOC_QBUF: {
        if (!dev->streaming && dev->fail_qbuf) {
          errno = EINVAL;
          return -1;
        }
        if (dev->streaming && dev->stream_qbuf_errno != 0) {
          errno = dev->stream_qbuf_errno;
          return -1;
        }
        return 0;
      }
      case VIDIOC_STREAMON: {
        if (dev->fail_streamon) {
          errno = EIO;
          return -1;
        }
        std::lock_guard<std::mutex> lock(dev->mutex);
        dev->streaming = true;
        // Signal any frames pushed before STREAMON completed.
        if (dev->write_fd >= 0) {
          for (size_t i = 0; i < dev->pending_frames.size(); ++i) {
            const uint8_t signal = 1;
            std::ignore = write(dev->write_fd, &signal, 1);
          }
        }
        return 0;
      }
      case VIDIOC_STREAMOFF: {
        std::lock_guard<std::mutex> lock(dev->mutex);
        dev->streaming = false;
        return 0;
      }
      case VIDIOC_DQBUF: {
        if (dev->dqbuf_errno != 0) {
          errno = dev->dqbuf_errno;
          return -1;
        }
        std::lock_guard<std::mutex> lock(dev->mutex);
        if (dev->pending_frames.empty()) {
          errno = EAGAIN;
          return -1;
        }
        uint8_t signal = 0;
        std::ignore = read(dev->read_fd, &signal, 1);
        const uint32_t idx =
            dev->next_index % static_cast<uint32_t>(dev->mapped_buffers.size());
        dev->next_index++;
        if (dev->pending_frames.front().size() >
            dev->mapped_buffers[idx].size()) {
          dev->pending_frames.pop_front();
          errno = EOVERFLOW;
          return -1;
        }
        std::vector<uint8_t> frame = std::move(dev->pending_frames.front());
        dev->pending_frames.pop_front();
        std::copy(frame.begin(), frame.end(), dev->mapped_buffers[idx].begin());

        auto* buf = static_cast<struct v4l2_buffer*>(arg);
        buf->index = idx;
        buf->bytesused = static_cast<uint32_t>(frame.size());
        buf->flags = dev->flag_frames_as_corrupt ? V4L2_BUF_FLAG_ERROR : 0;
        return 0;
      }
      default:
        errno = ENOTTY;
        return -1;
    }
  }

  void* Mmap(void* addr, size_t length, int prot, int flags, int fd,
             off_t offset) override {
    (void)addr;
    (void)length;
    (void)prot;
    (void)flags;
    auto it = open_fds_.find(fd);
    if (it == open_fds_.end()) {
      errno = EBADF;
      return MAP_FAILED;
    }
    FakeV4l2Device* dev = it->second;
    if (dev->fail_mmap) {
      errno = ENOMEM;
      return MAP_FAILED;
    }
    const size_t idx = static_cast<size_t>(offset / 4096);
    std::lock_guard<std::mutex> lock(dev->mutex);
    if (idx >= dev->mapped_buffers.size()) {
      errno = EINVAL;
      return MAP_FAILED;
    }
    dev->mmap_count++;
    void* ptr = dev->mapped_buffers[idx].data();
    mapped_ptrs_[ptr] = dev;
    return ptr;
  }

  int Munmap(void* addr, size_t length) override {
    (void)length;
    auto it = mapped_ptrs_.find(addr);
    if (it == mapped_ptrs_.end()) {
      errno = EINVAL;
      return -1;
    }
    it->second->munmap_count++;
    mapped_ptrs_.erase(it);
    return 0;
  }

  int Poll(struct pollfd* fds, nfds_t nfds, int timeout_ms) override {
    return poll(fds, nfds, timeout_ms);
  }

 private:
  std::vector<std::string> device_order_;
  std::map<std::string, std::unique_ptr<FakeV4l2Device>> devices_;
  std::map<int, FakeV4l2Device*> open_fds_;
  std::map<void*, FakeV4l2Device*> mapped_ptrs_;
};

}  // namespace test
}  // namespace camera_linux_v4l2

#endif  // PACKAGES_CAMERA_CAMERA_LINUX_V4L2_LINUX_TEST_FAKE_V4L2_SYSTEM_H_
