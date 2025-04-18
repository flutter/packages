# Example of using JavaScript with RFW

In this example, the application downloads both the RFW descriptions of 
UI and JavaScript logic that drives it. The Flutter application itself does 
not contain any of the calculator UI or logic.

It supports all Flutter platforms(use `package:jsf`), including macOS, 
Windows, Linux, Android, iOS, and Web.

## Running the Application

To run the application, simply execute: `flutter run`

## Conventions

The application renders the remote widget named `root` defined in the
`logic/calculator.rfw` file, and loads the JavaScript logic from the
`logic/calculator.js` file.

The JavaScript file must define a function `value` that takes no arguments
and returns an integer. This value is passed to the interface on startup.

That data is stored in the `value` key of the data exposed to the
remote widgets, as a map with two values, `numeric` (which stores the
integer as-is) and `string` (which stores its string representation,
e.g. for display using a `Text` widget).

The remote widgets can signal events. The names of such events are
looked up as functions in the JavaScript file. The `arguments` key, if
present, must be a list of integers to pass to the function.

Only the `core.widgets` local library is loaded into the runtime.
