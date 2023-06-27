# Example of using Wasm with RFW

In this example, the application downloads both RFW descriptions of UI
and Wasm logic to drive it. The Flutter application itself does not
contain any of the calculator UI or logic.

Currently, this example uses `package:wasm` on macOS, Windows, and Linux.
On web, it uses the Chrome browser APIs through JS interop. It does not
support Android, iOS, or other browsers.

## Building

Before running this package, you must run `dart run wasm:setup`
in this directory. Before doing this, you will need to have installed
Rust and clang.

To rebuild the files in the logic/ directory (which are the files that
the application downloads at runtime), you will additionally need to
have installed clang and lld, and dart must be on your path.

On macOS, clang from llvm (via Homebrew) is needed, since Xcode's clang
doesn't support Wasm.

Run `logic/build.sh` to rebuild the Wasm file.

## Running on the web

To use the binary encoding scheme from RFW (optional, but performance
optimizing), int64 is needed, but not supported in dart2js. Therefore,
in addition to the dynamically downloaded Wasm module, the web client
application itself needs to be compiled in dart2wasm as well.

To run the web app in Wasm,

`flutter build web --wasm`

Then you can host the website in `/build/web_wasm` your preferred way, such as
via the dhttp package.

## Conventions
;
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
