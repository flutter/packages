// Copyright 2020 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class DropdownMenu<T> extends StatelessWidget {
  final Map<String, T> items;

  final T initialValue;

  final String label;

  final TextStyle labelStyle;

  final ValueChanged<T> onChanged;

  final Color background;

  final EdgeInsetsGeometry padding;

  final Color menuItemBackground;

  final EdgeInsetsGeometry menuItemMargin;

  DropdownMenu({
    Key key,
    @required this.items,
    @required this.initialValue,
    @required this.label,
    this.labelStyle,
    Color background,
    EdgeInsetsGeometry padding,
    Color menuItemBackground,
    EdgeInsetsGeometry menuItemMargin,
    this.onChanged,
  })  : assert(items != null, 'The items map cannot be null'),
        assert(
            items.length > 0, 'The items map must contain at least one entry'),
        this.background = background ?? Colors.black12,
        this.padding =
            padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        this.menuItemBackground = menuItemBackground ?? Colors.white,
        this.menuItemMargin = menuItemMargin ?? EdgeInsets.only(left: 4),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      padding: padding,
      child: Row(
        children: [
          Text(
            label,
            style: labelStyle ?? Theme.of(context).textTheme.subtitle1,
          ),
          Container(
            color: menuItemBackground,
            margin: menuItemMargin,
            child: DropdownButton<T>(
              isDense: true,
              value: initialValue,
              items: [
                for (var item in items.keys)
                  DropdownMenuItem<T>(
                    child: Container(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(item),
                    ),
                    value: items[item],
                  ),
              ],
              onChanged: (value) => onChanged(value),
            ),
          ),
        ],
      ),
    );
  }
}
