/// The state of connection to an asynchronous computation.
///
/// The usual flow of state is as follows:
///
/// 1. [none], maybe with some initial data.
/// 2. [waiting], indicating that the asynchronous operation has begun,
///    typically with the data being null.
/// 3. [active], with data being non-null, and possible changing over time.
/// 4. [done], with data being non-null.
///
/// See also:
///
///  * [AsyncSnapshot], which augments a connection state with information
///    received from the asynchronous computation.
enum ConnectionState {
  /// Not currently connected to any asynchronous computation.
  ///
  /// For example, a [FutureBuilder] whose [FutureBuilder.future] is null.
  none,

  /// Connected to an asynchronous computation and awaiting interaction.
  waiting,

  /// Connected to an active asynchronous computation.
  ///
  /// For example, a [Stream] that has returned at least one value, but is not
  /// yet done.
  active,

  /// Connected to a terminated asynchronous computation.
  done,
}
