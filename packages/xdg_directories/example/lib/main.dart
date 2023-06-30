import 'package:flutter/material.dart';
import 'package:xdg_directories/xdg_directories.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          useMaterial3: true),
      home: const MyHomePage(title: 'Test package xdg_directories'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String payload = "empty";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(payload),
            const SizedBox(height: 20),

            /// The list of preference-ordered base directories relative to
            /// which configuration files should be searched. (Corresponds to
            /// `$XDG_CONFIG_DIRS`).
            ///
            /// Throws [StateError] if the HOME environment variable is not set
            ElevatedButton(
                key: const Key("getConfigXdgDirectory"),
                onPressed: () {
                  payload = configDirs.toString();
                  setState(() {});
                },
                child: const Text("Get config xdg directory")),
            const SizedBox(height: 10),

            /// The base directory relative to which user-specific
            /// non-essential (cached) data should be written. (Corresponds to
            /// `$XDG_CACHE_HOME`).
            ///
            /// Throws [StateError] if the HOME environment variable is not set.
            ElevatedButton(
                key: const Key("getCacheHome"),
                onPressed: () {
                  payload = cacheHome.toString();
                  setState(() {});
                },
                child: const Text("Get Cache Home")),
            const SizedBox(height: 10),

            /// The a single base directory relative to which user-specific
            /// configuration files should be written. (Corresponds to `$XDG_CONFIG_HOME`).
            ///
            /// Throws [StateError] if the HOME environment variable is not set.
            ElevatedButton(
                key: const Key("getConfigHome"),
                onPressed: () {
                  payload = configHome.toString();
                  setState(() {});
                },
                child: const Text("Get config Home")),
            const SizedBox(height: 10),

            /// The list of preference-ordered base directories relative to
            /// which data files should be searched. (Corresponds to `$XDG_DATA_DIRS`).
            ///
            /// Throws [StateError] if the HOME environment variable is not set.
            ElevatedButton(
                key: const Key("getDataDirectory"),
                onPressed: () {
                  payload = dataDirs.toString();
                  setState(() {});
                },
                child: const Text("Get data directory")),

            const SizedBox(height: 10),

            /// The base directory relative to which user-specific data files should be
            /// written. (Corresponds to `$XDG_DATA_HOME`).
            ///
            /// Throws [StateError] if the HOME environment variable is not set.
            ElevatedButton(
                key: const Key("getDataHome"),
                onPressed: () {
                  payload = dataHome.toString();
                  setState(() {});
                },
                child: const Text("Get data home")),
            const SizedBox(height: 10),

            /// The base directory relative to which user-specific runtime
            /// files and other file objects should be placed. (Corresponds to
            /// `$XDG_RUNTIME_DIR`).
            ///
            /// Throws [StateError] if the HOME environment variable is not set.
            ElevatedButton(
                key: const Key("getRuntimeDir"),
                onPressed: () {
                  payload = runtimeDir.toString();
                  setState(() {});
                },
                child: const Text("Get runtime dir")),
            const SizedBox(height: 10),

            /// Gets the set of user directory names that xdg knows about.
            ///
            /// These are not paths, they are names of xdg values.  Call [getUserDirectory]
            /// to get the associated directory.
            ///
            /// These are the names of the variables in "[configHome]/user-dirs.dirs", with
            /// the `XDG_` prefix removed and the `_DIR` suffix removed.

            ElevatedButton(
                key: const Key("getUserDirectoryNames"),
                onPressed: () {
                  payload = getUserDirectoryNames().toString();
                  setState(() {});
                },
                child: const Text("Get user directory names")),
            const SizedBox(height: 10),

            /// Gets the xdg user directory named by `dirName`.
            ///
            /// Use [getUserDirectoryNames] to find out the list of available names.
            ///
            /// If the `xdg-user-dir` executable is not present this returns null.
            ElevatedButton(
                key: const Key("getUserDirectoryName"),
                onPressed: () {
                  payload = getUserDirectory("").toString();
                  setState(() {});
                },
                child: const Text("Get user directory name")),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
