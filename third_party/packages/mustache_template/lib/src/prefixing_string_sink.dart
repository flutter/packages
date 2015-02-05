part of mustache;

class PrefixingStringSink implements StringSink {
    
  bool _started = false;
  final StringSink _sink;
  final String _prefix;

  PrefixingStringSink(this._sink, this._prefix);

  void write(Object obj) {
    if (!_started) {
      _started = true;
      _sink.write(_prefix);
    }
    var s = obj.toString();
    _sink.write(s.replaceAll('\n', '\n$_prefix'));
  }
  
  void writeCharCode(int charCode) {
    if (!_started) {
      _started = true;
      _sink.write(_prefix);
    }
    _sink.writeCharCode(charCode);
    if (charCode == _NEWLINE) _sink.write(_prefix);
  }

  void writeAll(Iterable objects, [String separator = ""]) {
    Iterator iterator = objects.iterator;
    if (!iterator.moveNext()) return;
    if (separator.isEmpty) {
      do {
        write(iterator.current);
      } while (iterator.moveNext());
    } else {
      write(iterator.current);
      while (iterator.moveNext()) {
        write(separator);
        write(iterator.current);
      }
    }
  }

  void writeln([Object obj = ""]) {
    write(obj);
    _sink.write('\n');
    _sink.write(_prefix);
  }

}
