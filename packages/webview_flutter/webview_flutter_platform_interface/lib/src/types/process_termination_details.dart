import 'package:flutter/foundation.dart';

/// This class provides more specific information about why the render process exited.
/// The application may use this to decide how to handle the situation.
@immutable
class ProcessTerminationDetails {
  /// Creates a [ProcessTerminationDetails].
  const ProcessTerminationDetails({
    required this.didCrash,
    required this.rendererPriorityAtExit,
  });

  /// Indicates whether the render process was observed to crash, or whether it was killed by the system.
  final bool didCrash;

  /// Returns the renderer priority that was set at the time that the renderer exited.
  final int rendererPriorityAtExit;
}
