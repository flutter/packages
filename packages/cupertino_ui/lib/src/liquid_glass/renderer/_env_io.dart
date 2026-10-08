import 'dart:io';

/// True if running in a test environment.
final bool isTestEnvironment = Platform.environment.containsKey('FLUTTER_TEST');
