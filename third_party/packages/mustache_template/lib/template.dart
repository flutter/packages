part of mustache;

// http://mustache.github.com/mustache.5.html

class Node {
	Node(this.type, this.value);
	final int type;
	final String value;
	final List<Node> children = new List<Node>();
	String toString() => 'Node: ${tokenTypeString(type)}';
}

Node _parse(List<_Token> tokens) {
	var stack = new List<Node>()..add(new Node(_OPEN_SECTION, 'root'));
	for (var t in tokens) {
		if (t.type == _TEXT || t.type == _VARIABLE) {
			stack.last.children.add(new Node(t.type, t.value));
		} else if (t.type == _OPEN_SECTION || t.type == _OPEN_INV_SECTION) {
			var child = new Node(t.type, t.value);
			stack.last.children.add(child);
			stack.add(child);
		} else if (t.type == _CLOSE_SECTION) {
			assert(stack.last.value == t.value); //FIXME throw an exception if these don't match.
			stack.removeLast();
		} else {
			throw new UnimplementedError();
		}
	}

	return stack.last;
}

class _Template {
	_Template(String source) 
		: _root = _parse(_scan(source));

	final Node _root;
	final ctl = new List(); //TODO StreamController();
	final stack = new List();

	render(values) {
		ctl.clear();
		stack.clear();
		stack.add(values);	
		_root.children.forEach(_renderNode);
		return ctl;
	}

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
		ctl.add(node.value);
	}

	_renderVariable(node) {
		final value = stack.last[node.value]; //TODO optional warning if variable is null or missing.
		final s = _htmlEscape(value.toString());
		ctl.add(s);
	}

	_renderSectionWithValue(node, value) {
		stack.add(value);
		node.children.forEach(_renderNode);
		stack.removeLast();
	}

	_renderSection(node) {
		final value = stack.last[node.value];
		if (value is List) {
			value.forEach((v) => _renderSectionWithValue(node, v));
		} else if (value is Map) {
			_renderSectionWithValue(node, value);
		} else if (value == true) {
			_renderSectionWithValue(node, {});
		} else {
			print('boom!'); //FIXME
		}
	}

	_renderInvSection(node) {
		final val = stack.last[node.value];
		if ((val is List && val.isEmpty)
				|| val == null
				|| val == false) {
			_renderSectionWithValue(node, {});
		}
	}

	/*
	escape

	& --> &amp;
	< --> &lt;
	> --> &gt;
	" --> &quot;
	' --> &#x27;     &apos; not recommended because its not in the HTML spec (See: section 24.4.1) &apos; is in the XML and XHTML specs.
	/ --> &#x2F; 
	*/
	//TODO
	String _htmlEscape(String s) {
		return s;
	}
}

_visit(Node root, visitor(Node n)) {
	var stack = new List<Node>()..add(root);
	while (!stack.isEmpty) {
		var node = stack.removeLast();
		stack.addAll(node.children);
		visitor(node);
	}
}
