#!/usr/bin/env python3
"""Feed synthetic frames into a v4l2loopback device, for testing without a
webcam.

    sudo modprobe v4l2loopback video_nr=42 card_label=camera_linux_test exclusive_caps=1
    python3 tool/v4l2loopback_feed.py /dev/video42 --text 'hello' --format yuyv

Then `CAMERA_LINUX_DEVICE=/dev/video42 dart test`, or run an app that uses
camera_linux. Each frame shows a QR code of --text (package `qrcode`, falls
back to a checkerboard when it is not installed) plus a moving bar so that
frames differ. --format mjpeg writes JPEG frames; --strip-dht removes their
Huffman tables, which is what many UVC cameras do and what the library
repairs.

Only numpy and Pillow are required.
"""

import argparse
import fcntl
import io
import struct
import sys
import time

import numpy as np
from PIL import Image, ImageDraw

V4L2_BUF_TYPE_VIDEO_OUTPUT = 2
V4L2_FIELD_NONE = 1
VIDIOC_S_FMT = 0xC0D05605  # _IOWR('V', 5, struct v4l2_format), 208 bytes on 64-bit

FOURCC = {
    "yuyv": b"YUYV",
    "rgb24": b"RGB3",
    "bgr24": b"BGR3",
    "grey": b"GREY",
    "mjpeg": b"MJPG",
}


def fourcc_code(code: bytes) -> int:
    return code[0] | (code[1] << 8) | (code[2] << 16) | (code[3] << 24)


def set_output_format(fd: int, width: int, height: int, fmt: str) -> None:
    bpp = {"yuyv": 2, "rgb24": 3, "bgr24": 3, "grey": 1, "mjpeg": 0}[fmt]
    bytesperline = width * bpp
    sizeimage = bytesperline * height if bpp else width * height * 2
    pix = struct.pack(
        "<12I",
        width,
        height,
        fourcc_code(FOURCC[fmt]),
        V4L2_FIELD_NONE,
        bytesperline,
        sizeimage,
        0,  # colorspace: default
        0,  # priv
        0,  # flags
        0,  # ycbcr_enc
        0,  # quantization
        0,  # xfer_func
    )
    buf = bytearray(208)
    struct.pack_into("<I", buf, 0, V4L2_BUF_TYPE_VIDEO_OUTPUT)
    buf[8 : 8 + len(pix)] = pix
    fcntl.ioctl(fd, VIDIOC_S_FMT, buf)


def make_base_image(width: int, height: int, text: str) -> Image.Image:
    img = Image.new("RGB", (width, height), (235, 235, 235))
    size = min(width, height) * 3 // 4
    try:
        import qrcode  # type: ignore

        qr = qrcode.QRCode(border=2)
        qr.add_data(text)
        qr.make(fit=True)
        code = qr.make_image(fill_color="black", back_color="white").convert("RGB")
        code = code.resize((size, size), Image.NEAREST)
    except ImportError:
        print("package qrcode not installed; drawing a checkerboard", file=sys.stderr)
        code = Image.new("RGB", (size, size), "white")
        d = ImageDraw.Draw(code)
        cell = size // 8
        for y in range(8):
            for x in range(8):
                if (x + y) % 2 == 0:
                    d.rectangle([x * cell, y * cell, (x + 1) * cell - 1, (y + 1) * cell - 1], fill="black")
    img.paste(code, ((width - size) // 2, (height - size) // 2))
    return img


def rgb_to_yuyv(rgb: np.ndarray) -> bytes:
    # BT.601 limited range, matching what the library expects from webcams.
    r = rgb[..., 0].astype(np.float32)
    g = rgb[..., 1].astype(np.float32)
    b = rgb[..., 2].astype(np.float32)
    y = 16 + 0.257 * r + 0.504 * g + 0.098 * b
    u = 128 - 0.148 * r - 0.291 * g + 0.439 * b
    v = 128 + 0.439 * r - 0.368 * g - 0.071 * b
    y = np.clip(y, 16, 235).astype(np.uint8)
    u = np.clip(u, 16, 240).astype(np.uint8)
    v = np.clip(v, 16, 240).astype(np.uint8)
    h, w = y.shape
    out = np.empty((h, w * 2), dtype=np.uint8)
    out[:, 0::2] = y
    out[:, 1::4] = u[:, 0::2]
    out[:, 3::4] = v[:, 0::2]
    return out.tobytes()


def strip_dht(jpeg: bytes) -> bytes:
    out = bytearray(jpeg[:2])
    pos = 2
    while pos + 4 <= len(jpeg):
        marker = jpeg[pos + 1]
        if marker == 0xDA:
            out += jpeg[pos:]
            return bytes(out)
        seg_len = (jpeg[pos + 2] << 8) | jpeg[pos + 3]
        if marker != 0xC4:
            out += jpeg[pos : pos + 2 + seg_len]
        pos += 2 + seg_len
    raise ValueError("no scan in JPEG")


def encode(img: Image.Image, fmt: str, no_dht: bool) -> bytes:
    if fmt == "mjpeg":
        buf = io.BytesIO()
        img.save(buf, format="JPEG", quality=85)
        return strip_dht(buf.getvalue()) if no_dht else buf.getvalue()
    arr = np.asarray(img)
    if fmt == "yuyv":
        return rgb_to_yuyv(arr)
    if fmt == "rgb24":
        return arr.tobytes()
    if fmt == "bgr24":
        return arr[..., ::-1].tobytes()
    if fmt == "grey":
        return np.asarray(img.convert("L")).tobytes()
    raise ValueError(fmt)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("device", help="v4l2loopback node, e.g. /dev/video42")
    ap.add_argument("--text", default="camera_linux test", help="QR code contents")
    ap.add_argument("--format", choices=sorted(FOURCC), default="yuyv")
    ap.add_argument("--width", type=int, default=640)
    ap.add_argument("--height", type=int, default=480)
    ap.add_argument("--fps", type=float, default=10)
    ap.add_argument("--strip-dht", action="store_true", help="with --format mjpeg: omit Huffman tables")
    ap.add_argument("--frames", type=int, default=0, help="stop after this many frames (0 = run until interrupted)")
    args = ap.parse_args()

    base = make_base_image(args.width, args.height, args.text)
    with open(args.device, "wb", buffering=0) as dev:
        set_output_format(dev.fileno(), args.width, args.height, args.format)
        print(f"writing {args.format} {args.width}x{args.height} to {args.device}", file=sys.stderr)
        n = 0
        period = 1.0 / args.fps
        while args.frames == 0 or n < args.frames:
            frame = base.copy()
            bar_x = int((n * 7) % args.width)
            ImageDraw.Draw(frame).rectangle([bar_x, 0, bar_x + 6, 12], fill=(200, 30, 30))
            dev.write(encode(frame, args.format, args.strip_dht))
            n += 1
            time.sleep(period)
    return 0


if __name__ == "__main__":
    sys.exit(main())
