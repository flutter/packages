part of mustache;

class _Node {
	_Node(this.type, this.value, this.line, this.column);
	_Node.fromToken(_Token token)
		: type = token.type,
		  value = token.value,
		  line = token.line,
		  column = token.column;
	final int type;
	final String value;
	final int line;
	final int column;
	final List<_Node> children = new List<_Node>();
	String toString() => '_Node: ${tokenTypeString(type)}';
}

_Node _parse(List<_Token> tokens) {
	var stack = new List<_Node>()..add(new _Node(_OPEN_SECTION, 'root', 0, 0));
	for (var t in tokens) {
		if (t.type == _TEXT || t.type == _VARIABLE) {
			stack.last.children.add(new _Node.fromToken(t));
		} else if (t.type == _OPEN_SECTION || t.type == _OPEN_INV_SECTION) {
			//TODO in strict mode limit characters allowed in tag names.
			var child = new _Node.fromToken(t);
			stack.last.children.add(child);
			stack.add(child);

		} else if (t.type == _CLOSE_SECTION) {
			//TODO in strict mode limit characters allowed in tag names.
			if (stack.last.value != t.value) {
				throw new MustacheFormatException('Mismatched tag, '
					"expected: '${stack.last.value}', "
					"was: '${t.value}', "
					'at: ${t.line}:${t.column}.', t.line, t.column);
			}

			stack.removeLast();
		} else {
			throw new UnimplementedError();
		}
	}

	return stack.last;
}

class _Template implements Template {
	_Template(String source) 
			: _root = _parse(_scan(source)) {
		_htmlEscapeMap[_AMP] = '&amp;';
		_htmlEscapeMap[_LT] = '&lt;';
		_htmlEscapeMap[_GT] = '&gt;';
		_htmlEscapeMap[_QUOTE] = '&quot;';
		_htmlEscapeMap[_APOS] = '&#x27;';
		_htmlEscapeMap[_FORWARD_SLASH] = '&#x2F;';
	}

	final _Node _root;
	final _buffer = new StringBuffer();
	final _stack = new List();
	final _htmlEscapeMap = new Map<int, String>();

	render(values) {
		_buffer.clear();
		_stack.clear();
		_stack.add(values);	
		_root.children.forEach(_renderNode);
		var s = _buffer.toString();
		_buffer.clear();
		return s;
	}

	_write(String output) => _buffer.write(output);

	_renderNode(node) {
		switch (node.type) {
			case _TEXT:
				_renderText(node);
				break;
			case _VARIABLE:
				_renderVariable(node);
				break;
			case _OPEN_SECTION:
				_renderSection(node);
				break;
			case _OPEN_INV_SECTION:
				_renderInvSection(node);
				break;
			default:
				throw new UnimplementedError();
		}
	}

	_renderText(node) {
		_write(node.value);
	}

	_renderVariable(node) {
		final value = _stack.last[node.value];

		if (value == null) {
			//FIXME in strict mode throw an error.
		} else {
			_write(_htmlEscape(value.toString()));
		}
	}

	_renderSectionWithValue(node, value) {
		_stack.add(value);
		node.children.forEach(_renderNode);
		_stack.removeLast();
	}

	_renderSection(node) {
		final value = _stack.last[node.value];
		if (value is List) {
			value.forEach((v) => _renderSectionWithValue(node, v));
		} else if (value is Map) {
			_renderSectionWithValue(node, value);
		} else if (value == true) {
			_renderSectionWithValue(node, {});
		} else if (value == false) {
			// Do nothing.
		} else if (value == null) {
			// Do nothing.
			// FIXME in strict mode, log an error.
		} else {
			throw new FormatException("Invalid value type for section: '${node.value}', type: ${value.runtimeType}.");
		}
	}

	_renderInvSection(node) {
		final value = _stack.last[node.value];
		if ((value is List && value.isEmpty)
				|| value == null
				|| value == false) {
			// FIXME in strict mode, log an error if value is null.
			_renderSectionWithValue(node, {});
		} else if (value == true || value is Map || value is List) {
			// Do nothing.
		} else {
			throw new FormatException("Invalid value type for inverse section: '${node.value}', type: ${value.runtimeType}.");	
		}
	}

	String _htmlEscape(String s) {
		var buffer = new StringBuffer();
		int startIndex = 0;
		int i = 0;
		for (int c in s.runes) {			
			if (c == _AMP
					|| c == _LT
					|| c == _GT
					|| c == _QUOTE
					|| c == _APOS
					|| c == _FORWARD_SLASH) {
				buffer.write(s.substring(startIndex, i));
				buffer.write(_htmlEscapeMap[c]);
				startIndex = i + 1;
			}
			i++;
		}
		buffer.write(s.substring(startIndex));			
		return buffer.toString();
	}
}

_visit(_Node root, visitor(_Node n)) {
	var _stack = new List<_Node>()..add(root);
	while (!_stack.isEmpty) {
		var node = _stack.removeLast();
		_stack.addAll(node.children);
		visitor(node);
	}
}
