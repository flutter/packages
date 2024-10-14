package io.flutter.plugins.camera;

import androidx.annotation.NonNull;

/** A convenience class for results of a Pigeon Flutter API method call that perform no action. */
public class NoOpVoidResult implements Messages.VoidResult {
  @Override
  public void success() {}

  @Override
  public void error(@NonNull Throwable error) {}
}
