// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// internals

enum Ops { opNone, opAdd };

int _pending = 0;
Ops _pendingOp = opNone;
int _display = 0;
bool _displayLocked = false;

void _resolve() {
  switch (_pendingOp) {
    case opNone:
      break;
    case opAdd:
      _display += _pending;
      break;
  }
}

// public API

extern "C" int value() { return _display; }

extern "C" void digit(int n) {
  if (_displayLocked) {
    _display = 0;
  }
  _display *= 10;
  _display += n;
  _displayLocked = false;
}

extern "C" void add() {
  _resolve();
  _pending = _display;
  _pendingOp = opAdd;
  _display = 0;
  _displayLocked = false;
}

extern "C" void equals() {
  int current = _displayLocked ? _pending : _display;
  _resolve();
  _pending = current;
  _displayLocked = true;
}
