# Example of using Wasm with RFW

In this example, the application downloads both RFW descriptions of UI
and Wasm logic to drive it. The Flutter application itself does not
contain any of the calculator UI or logic.

Currently this only runs on macOS, Windows, and Linux, since
`package:wasm` does not yet support Android, iOS, or web.

## Building

Before running this package, you must run `flutter pub run wasm:setup`
in this directory. Before doing this, you will need to have installed
Rust and clang.

To rebuild the files in the logic/ directory (which are the files that
the application downloads at runtime), you will additionally need to
have installed clang and lld, and dart must be on your path.

## Conventions

The application renders the remote widget named `root` defined in the
`logic/calculator.rfw` file, and loads the Wasm module defined in the
`logic/calculator.wasm` file.

The Wasm module must implement a function `value` that takes no
arguments and returns an integer, which is the data to pass to the
interface. This will be the first function called.

That data is stored in the `value` key of the data exposed to the
remote widgets, as a map with two values, `numeric` (which stores the
integer as-is) and `string` (which stores its string representation,
e.g. for display using a `Text` widget).

The remote widgets can signal events. The names of such events are
looked up as functions in the Wasm module. The `arguments` key, if
present, must be a list of integers to pass to the function.

Only the `core.widgets` local library is loaded into the runtime.

## Application behavior

The demo application fetches the RFW and Wasm files on startup, if it
has not downloaded them before or if they were downloaded more than
six hours earlier.
