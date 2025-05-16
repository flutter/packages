var _pending = 0;
var _pendingOp = 'none';
var _display = 0;
var _displayLocked = false;

function _resolve() {
  if (_pendingOp === 'add') {
    _display = _pending + _display;
  }
}

function value() {
  return _display;
}

function digit(n) {
  if (_displayLocked) {
    _display = 0;
  }
  _display = _display * 10 + n;
  _displayLocked = false;
}

function add() {
  _resolve();
  _pending = _display;
  _pendingOp = 'add';
  _display = 0;
  _displayLocked = false;
}

function equals() {
  var current = _display;
  if (_displayLocked) {
    current = _pending;
  }
  _resolve();
  _pending = current;
  _displayLocked = true;
}
