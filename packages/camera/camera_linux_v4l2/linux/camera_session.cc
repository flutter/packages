// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "camera_session.h"

#include <errno.h>
#include <fcntl.h>
#include <linux/videodev2.h>
#include <poll.h>
#include <sys/eventfd.h>
#include <sys/mman.h>
#include <unistd.h>

#include <algorithm>
#include <cstring>
#include <tuple>
#include <utility>

namespace camera_linux_v4l2 {
namespace {

constexpr unsigned int kBufferCount = 4;

// Bounds format enumeration in case a driver never ends its list.
constexpr uint32_t kMaxEnumeratedFormats = 64;

// A camera that cannot sustain the negotiated format, for example over a slow
// USB link, returns only corrupt frames. After this many in a row the session
// reports an error rather than leaving the preview blank indefinitely.
constexpr int kMaxConsecutiveCorruptFrames = 30;

// Opens `path` and checks that it is a streaming video capture device that
// offers a supported pixel format. Returns the open descriptor and sets
// `fourcc` to the preferred format, or returns -1 and describes the failure in
// `error_code` and `error_message`.
int OpenCaptureDevice(V4l2System* system, const std::string& path,
                      uint32_t* fourcc, std::string* error_code,
                      std::string* error_message) {
  *error_code = "camera_error";
  const int fd = system->Open(path.c_str(), O_RDWR | O_NONBLOCK | O_CLOEXEC);
  if (fd < 0) {
    const int err = errno;
    if (err == EACCES || err == EPERM) {
      *error_code = "CameraAccessDenied";
    }
    *error_message = path + ": " + g_strerror(err);
    return -1;
  }

  struct v4l2_capability cap;
  std::memset(&cap, 0, sizeof(cap));
  if (system->Ioctl(fd, VIDIOC_QUERYCAP, &cap) < 0) {
    *error_message = path + ": not a V4L2 device";
    system->Close(fd);
    return -1;
  }

  // A UVC camera exposes a second, metadata-only node whose driver-wide
  // `capabilities` still advertise video capture, so prefer `device_caps`.
  const uint32_t caps = (cap.capabilities & V4L2_CAP_DEVICE_CAPS)
                            ? cap.device_caps
                            : cap.capabilities;
  if (!(caps & V4L2_CAP_VIDEO_CAPTURE) || !(caps & V4L2_CAP_STREAMING)) {
    *error_message = path + ": not a streaming video capture device";
    system->Close(fd);
    return -1;
  }

  int best_rank = -1;
  for (uint32_t i = 0; i < kMaxEnumeratedFormats; ++i) {
    struct v4l2_fmtdesc desc;
    std::memset(&desc, 0, sizeof(desc));
    desc.index = i;
    desc.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if (system->Ioctl(fd, VIDIOC_ENUM_FMT, &desc) < 0) {
      break;
    }
    const int rank = PixelFormatRank(desc.pixelformat);
    if (rank >= 0 && (best_rank < 0 || rank < best_rank)) {
      best_rank = rank;
      *fourcc = desc.pixelformat;
    }
  }
  if (best_rank < 0) {
    *error_message = path + ": no supported pixel format";
    system->Close(fd);
    return -1;
  }
  return fd;
}

}  // namespace

std::vector<std::string> EnumerateVideoDevices(V4l2System* system) {
  std::vector<std::string> result;
  for (const std::string& path : system->ListVideoDevices()) {
    uint32_t fourcc = 0;
    std::string error_code;
    std::string error_message;
    const int fd =
        OpenCaptureDevice(system, path, &fourcc, &error_code, &error_message);
    if (fd >= 0) {
      system->Close(fd);
      result.push_back(path);
    }
  }
  return result;
}

CameraSession::CameraSession(V4l2System* system, std::string device_path,
                             uint32_t requested_width,
                             uint32_t requested_height)
    : system_(system),
      device_path_(std::move(device_path)),
      requested_width_(requested_width),
      requested_height_(requested_height) {}

CameraSession::~CameraSession() {
  Stop();
  CameraPixelBufferFree(&work_rgba_);
}

bool CameraSession::Start(FrameCallback on_frame, ErrorCallback on_error,
                          std::string* error_code, std::string* error_message) {
  if (thread_ != nullptr) {
    return true;
  }

  if (!OpenAndNegotiate(error_code, error_message) ||
      !SetupMmapAndStream(error_message)) {
    CleanupResources();
    return false;
  }

  on_frame_ = std::move(on_frame);
  on_error_ = std::move(on_error);
  stop_.store(false);
  thread_ = g_thread_try_new("camera_linux_v4l2_capture",
                             &CameraSession::ThreadEntry, this, nullptr);
  if (thread_ == nullptr) {
    CleanupResources();
    *error_message = "Failed to create capture thread";
    return false;
  }
  return true;
}

void CameraSession::Stop() {
  stop_.store(true);
  if (wakeup_fd_ >= 0) {
    // Wakes the capture thread out of poll(). This write cannot block, and
    // only fails if a wakeup is already pending.
    const uint64_t one = 1;
    std::ignore = write(wakeup_fd_, &one, sizeof(one));
  }
  if (thread_ != nullptr) {
    g_thread_join(thread_);
    thread_ = nullptr;
  }
  CleanupResources();
}

bool CameraSession::OpenAndNegotiate(std::string* error_code,
                                     std::string* error_message) {
  uint32_t best_fourcc = 0;
  fd_ = OpenCaptureDevice(system_, device_path_, &best_fourcc, error_code,
                          error_message);
  if (fd_ < 0) {
    return false;
  }

  struct v4l2_format fmt;
  std::memset(&fmt, 0, sizeof(fmt));
  fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
  fmt.fmt.pix.width = requested_width_;
  fmt.fmt.pix.height = requested_height_;
  fmt.fmt.pix.pixelformat = best_fourcc;
  fmt.fmt.pix.field = V4L2_FIELD_ANY;
  if (system_->Ioctl(fd_, VIDIOC_S_FMT, &fmt) < 0) {
    const int err = errno;
    *error_message = std::string("VIDIOC_S_FMT: ") + g_strerror(err);
    return false;
  }

  // The driver may adjust both the format and the size, so validate what it
  // actually selected rather than what was requested.
  if (PixelFormatRank(fmt.fmt.pix.pixelformat) < 0) {
    *error_message = "Driver negotiated an unsupported pixel format";
    return false;
  }
  if (!GetRgbaBufferSize(fmt.fmt.pix.width, fmt.fmt.pix.height, &rgba_bytes_)) {
    *error_message = "Driver reported invalid frame dimensions";
    return false;
  }

  fourcc_ = fmt.fmt.pix.pixelformat;
  width_ = fmt.fmt.pix.width;
  height_ = fmt.fmt.pix.height;
  bytes_per_line_ = fmt.fmt.pix.bytesperline;
  return true;
}

bool CameraSession::SetupMmapAndStream(std::string* error_message) {
  struct v4l2_requestbuffers req;
  std::memset(&req, 0, sizeof(req));
  req.count = kBufferCount;
  req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
  req.memory = V4L2_MEMORY_MMAP;
  if (system_->Ioctl(fd_, VIDIOC_REQBUFS, &req) < 0) {
    const int err = errno;
    *error_message = std::string("VIDIOC_REQBUFS: ") + g_strerror(err);
    return false;
  }
  if (req.count < 2) {
    *error_message = "Driver granted fewer than 2 capture buffers";
    return false;
  }
  const unsigned int granted = std::min(req.count, kBufferCount);
  buffers_.reserve(granted);

  for (unsigned int i = 0; i < granted; ++i) {
    struct v4l2_buffer buf;
    std::memset(&buf, 0, sizeof(buf));
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_MMAP;
    buf.index = i;
    if (system_->Ioctl(fd_, VIDIOC_QUERYBUF, &buf) < 0) {
      const int err = errno;
      *error_message = std::string("VIDIOC_QUERYBUF: ") + g_strerror(err);
      return false;
    }
    if (buf.length == 0) {
      *error_message = "VIDIOC_QUERYBUF returned zero-length buffer";
      return false;
    }
    void* mapped = system_->Mmap(nullptr, buf.length, PROT_READ | PROT_WRITE,
                                 MAP_SHARED, fd_, buf.m.offset);
    if (mapped == MAP_FAILED) {
      const int err = errno;
      *error_message = std::string("mmap: ") + g_strerror(err);
      return false;
    }
    buffers_.push_back(MappedBuffer{mapped, buf.length});
  }

  for (unsigned int i = 0; i < buffers_.size(); ++i) {
    struct v4l2_buffer buf;
    std::memset(&buf, 0, sizeof(buf));
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_MMAP;
    buf.index = i;
    if (system_->Ioctl(fd_, VIDIOC_QBUF, &buf) < 0) {
      const int err = errno;
      *error_message = std::string("VIDIOC_QBUF: ") + g_strerror(err);
      return false;
    }
  }

  wakeup_fd_ = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
  if (wakeup_fd_ < 0) {
    const int err = errno;
    *error_message = std::string("eventfd: ") + g_strerror(err);
    return false;
  }

  enum v4l2_buf_type type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
  if (system_->Ioctl(fd_, VIDIOC_STREAMON, &type) < 0) {
    const int err = errno;
    *error_message = std::string("VIDIOC_STREAMON: ") + g_strerror(err);
    return false;
  }
  streaming_ = true;
  return true;
}

void CameraSession::CleanupResources() {
  if (fd_ >= 0) {
    if (streaming_) {
      enum v4l2_buf_type type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
      system_->Ioctl(fd_, VIDIOC_STREAMOFF, &type);
      streaming_ = false;
    }
    for (const MappedBuffer& buf : buffers_) {
      system_->Munmap(buf.start, buf.length);
    }
    buffers_.clear();
    system_->Close(fd_);
    fd_ = -1;
  }
  if (wakeup_fd_ >= 0) {
    close(wakeup_fd_);
    wakeup_fd_ = -1;
  }
}

gpointer CameraSession::ThreadEntry(gpointer data) {
  static_cast<CameraSession*>(data)->RunCaptureLoop();
  return nullptr;
}

void CameraSession::ReportError(const std::string& message) {
  // Failures caused by Stop() tearing the device down are not errors.
  if (!stop_.load() && on_error_) {
    on_error_(message);
  }
}

void CameraSession::RunCaptureLoop() {
  int corrupt_frames = 0;
  while (!stop_.load()) {
    struct pollfd fds[2];
    fds[0].fd = fd_;
    fds[0].events = POLLIN;
    fds[0].revents = 0;
    fds[1].fd = wakeup_fd_;
    fds[1].events = POLLIN;
    fds[1].revents = 0;

    if (system_->Poll(fds, 2, -1) < 0) {
      const int err = errno;
      if (err == EINTR) {
        continue;
      }
      ReportError(std::string("poll: ") + g_strerror(err));
      break;
    }
    if (stop_.load() || (fds[1].revents & POLLIN)) {
      break;
    }
    if (fds[0].revents & (POLLERR | POLLHUP | POLLNVAL)) {
      ReportError(device_path_ + ": device disconnected or errored");
      break;
    }
    if (!(fds[0].revents & POLLIN)) {
      continue;
    }

    struct v4l2_buffer buf;
    std::memset(&buf, 0, sizeof(buf));
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_MMAP;
    if (system_->Ioctl(fd_, VIDIOC_DQBUF, &buf) < 0) {
      const int err = errno;
      if (err == EAGAIN) {
        continue;
      }
      ReportError(std::string("VIDIOC_DQBUF: ") + g_strerror(err));
      break;
    }

    // Frames that are flagged as corrupt or fail conversion are dropped. The
    // driver-reported index and length are not trusted beyond the mapping.
    bool converted = false;
    if (buf.index < buffers_.size() && !(buf.flags & V4L2_BUF_FLAG_ERROR)) {
      const MappedBuffer& mapped = buffers_[buf.index];
      const size_t used = std::min<size_t>(buf.bytesused, mapped.length);
      converted = CameraPixelBufferEnsure(&work_rgba_, rgba_bytes_) &&
                  ConvertFrameToRgba(static_cast<const uint8_t*>(mapped.start),
                                     used, fourcc_, width_, height_,
                                     bytes_per_line_, work_rgba_.data);
    }
    if (converted) {
      corrupt_frames = 0;
      if (on_frame_) {
        on_frame_(&work_rgba_, width_, height_);
      }
    } else if (++corrupt_frames >= kMaxConsecutiveCorruptFrames) {
      ReportError(device_path_ + ": device is only producing corrupt frames");
      break;
    }

    if (system_->Ioctl(fd_, VIDIOC_QBUF, &buf) < 0) {
      const int err = errno;
      ReportError(std::string("VIDIOC_QBUF: ") + g_strerror(err));
      break;
    }
  }
}

}  // namespace camera_linux_v4l2
