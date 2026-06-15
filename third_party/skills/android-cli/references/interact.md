Title: Live Content

Description: Fetched live

Source: https://raw.githubusercontent.com/android/skills/main/devtools/android-cli/references/interact.md

---

# Tools
Run `android layout --help` and `android screen --help`.

## UI Dump
`android layout`  returns a flat JSON list of the UI elements on screen.
`android layout --diff` returns a flat JSON list of the UI elements that have changed since the last call to `layout` or `layout --diff`

Each JSON object represents a UI element in the Android app. The following properties may be present:
- `text` - any literal text the element contains
- `resourceId` - the Android resource id used to refer to the element
- `contentDesc` - a description of a UI element for use by accessibility tools
- `interactions` - the set of user interactions the element supports. May contain one or more of: `checkable`, `clickable`, `focusable`, `scrollable`, `long-clickable`, `password`
- `state` - the set of states the element is in. May contain one or more of `checked`, `focused`, `selected`
- `bounds` - the screen coordinates of the bounding rectangle of the element, in the format `[min X,min Y][max X, max Y]`
- `center` - the screen coordinates of the center of the element, in the format `[x,y]`
- `off-screen` - if true, the element is in the UI hierarchy but not visible; it may require scrolling to view.

Use `layout` as a primary means of examining an Android app. Use `layout --diff` to focus on changes and to keep your context small.
Example: When entering digits into a calculator, use `layout --diff` to output only the digit readout element.

`layout` may fail due to the app displaying a WebView or animation; in these cases, use `android screen --annotate` to inspect the app.
This failure will likely resolve after navigating away from the current screen.

## Screenshot
`android screen capture -o <file path>` saves a PNG of the current device screen to `<file path>`

Use `screen capture` as a secondary me

