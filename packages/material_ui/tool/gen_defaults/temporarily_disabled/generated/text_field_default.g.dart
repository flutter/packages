// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

TextStyle? _m3StateInputStyle(BuildContext context) =>
    WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.38));
      }
      return TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color);
    });

TextStyle _m3InputStyle(BuildContext context) => Theme.of(context).textTheme.bodyLarge!;

TextStyle _m3CounterErrorStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.error);
