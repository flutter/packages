// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.imagepicker.Messages.CacheRetrievalResult;
import io.flutter.plugins.imagepicker.Messages.FlutterError;
import io.flutter.plugins.imagepicker.Messages.GeneralOptions;
import io.flutter.plugins.imagepicker.Messages.ImagePickerApi;
import io.flutter.plugins.imagepicker.Messages.ImageSelectionOptions;
import io.flutter.plugins.imagepicker.Messages.MediaSelectionOptions;
import io.flutter.plugins.imagepicker.Messages.Result;
import io.flutter.plugins.imagepicker.Messages.SourceCamera;
import io.flutter.plugins.imagepicker.Messages.SourceSpecification;
import io.flutter.plugins.imagepicker.Messages.VideoSelectionOptions;
import java.util.List;

@SuppressWarnings("deprecation")
public class ImagePickerPlugin implements FlutterPlugin, ActivityAware, ImagePickerApi {

  private class LifeCycleObserver
      implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
    private final Activity thisActivity;

    LifeCycleObserver(Activity activity) {
      this.thisActivity = activity;
    }

    @Override
    public void onCreate(@NonNull LifecycleOwner owner) {}

    @Override
    public void onStart(@NonNull LifecycleOwner owner) {}

    @Override
    public void onResume(@NonNull LifecycleOwner owner) {}

    @Override
    public void onPause(@NonNull LifecycleOwner owner) {}

    @Override
    public void onStop(@NonNull LifecycleOwner owner) {
      onActivityStopped(thisActivity);
    }

    @Override
    public void onDestroy(@NonNull LifecycleOwner owner) {
      onActivityDestroyed(thisActivity);
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}

    @Override
    public void onActivityStarted(Activity activity) {}

    @Override
    public void onActivityResumed(Activity activity) {}

    @Override
    public void onActivityPaused(Activity activity) {}

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

    @Override
    public void onActivityDestroyed(Activity activity) {
      if (thisActivity == activity && activity.getApplicationContext() != null) {
        ((Application) activity.getApplicationContext())
            .unregisterActivityLifecycleCallbacks(
                this); // Use getApplicationContext() to avoid casting failures
      }
    }

    @Override
    public void onActivityStopped(Activity activity) {
      if (thisActivity == activity) {
        activityState.getDelegate().saveStateBeforeResult();
      }
    }
  }

  /**
   * Move all activity-lifetime-bound states into this helper object, so that {@code setup} and
   * {@code tearDown} would just become constructor and finalize calls of the helper object.
   */
  private class ActivityState {
    private Application application;
    private Activity activity;
    private ImagePickerDelegate delegate;
    private LifeCycleObserver observer;
    private ActivityPluginBinding activityBinding;
    private BinaryMessenger messenger;

    // This is null when not using v2 embedding;
    private Lifecycle lifecycle;

    // Default constructor
    ActivityState(
        final Application application,
        final Activity activity,
        final BinaryMessenger messenger,
        final ImagePickerApi handler,
        final ActivityPluginBinding activityBinding) {
      this.application = application;
      this.activity = activity;
      this.activityBinding = activityBinding;
      this.messenger = messenger;

      delegate = constructDelegate(activity);
      ImagePickerApi.setUp(messenger, handler);
      observer = new LifeCycleObserver(activity);

      // V2 embedding setup for activity listeners.
      activityBinding.addActivityResultListener(delegate);
      activityBinding.addRequestPermissionsResultListener(delegate);
      lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(activityBinding);
      lifecycle.addObserver(observer);
    }

    // Only invoked by {@link #ImagePickerPlugin(ImagePickerDelegate, Activity)} for testing.
    ActivityState(final ImagePickerDelegate delegate, final Activity activity) {
      this.activity = activity;
      this.delegate = delegate;
    }

    void release() {
      if (activityBinding != null) {
        activityBinding.removeActivityResultListener(delegate);
        activityBinding.removeRequestPermissionsResultListener(delegate);
        activityBinding = null;
      }

      if (lifecycle != null) {
        lifecycle.removeObserver(observer);
        lifecycle = null;
      }

      ImagePickerApi.setUp(messenger, null);

      if (application != null) {
        application.unregisterActivityLifecycleCallbacks(observer);
        application = null;
      }

      activity = null;
      observer = null;
      delegate = null;
    }

    Activity getActivity() {
      return activity;
    }

    ImagePickerDelegate getDelegate() {
      return delegate;
    }
  }

  private FlutterPluginBinding pluginBinding;
  ActivityState activityState;

  /**
   * Default constructor for the plugin.
   *
   * <p>Use this constructor for production code.
   */
  // See also: * {@link #ImagePickerPlugin(ImagePickerDelegate, Activity)} for testing.
  public ImagePickerPlugin() {}

  @VisibleForTesting
  ImagePickerPlugin(final ImagePickerDelegate delegate, final Activity activity) {
    activityState = new ActivityState(delegate, activity);
  }

  @VisibleForTesting
  final ActivityState getActivityState() {
    return activityState;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    pluginBinding = binding;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    setup(
        pluginBinding.getBinaryMessenger(),
        (Application) pluginBinding.getApplicationContext(),
        binding.getActivity(),
        binding);
  }

  @Override
  public void onDetachedFromActivity() {
    tearDown();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  private void setup(
      final BinaryMessenger messenger,
      final Application application,
      final Activity activity,
      final ActivityPluginBinding activityBinding) {
    activityState = new ActivityState(application, activity, messenger, this, activityBinding);
  }

  private void tearDown() {
    if (activityState != null) {
      activityState.release();
      activityState = null;
    }
  }

  @VisibleForTesting
  final ImagePickerDelegate constructDelegate(final Activity setupActivity) {
    final ImagePickerCache cache = new ImagePickerCache(setupActivity);

    final ExifDataCopier exifDataCopier = new ExifDataCopier();
    final ImageResizer imageResizer = new ImageResizer(setupActivity, exifDataCopier);
    return new ImagePickerDelegate(setupActivity, imageResizer, cache);
  }

  private @Nullable ImagePickerDelegate getImagePickerDelegate() {
    if (activityState == null || activityState.getActivity() == null) {
      return null;
    }
    return activityState.getDelegate();
  }

  private void setCameraDevice(
      @NonNull ImagePickerDelegate delegate, @NonNull SourceSpecification source) {
    SourceCamera camera = source.getCamera();
    if (camera != null) {
      ImagePickerDelegate.CameraDevice device;
      switch (camera) {
        case FRONT:
          device = ImagePickerDelegate.CameraDevice.FRONT;
          break;
        case REAR:
        default:
          device = ImagePickerDelegate.CameraDevice.REAR;
          break;
      }
      delegate.setCameraDevice(device);
    }
  }

  @Override
  public void pickImages(
      @NonNull SourceSpecification source,
      @NonNull ImageSelectionOptions options,
      @NonNull GeneralOptions generalOptions,
      @NonNull Result<List<String>> result) {
    ImagePickerDelegate delegate = getImagePickerDelegate();
    if (delegate == null) {
      result.error(
          new FlutterError(
              "no_activity", "image_picker plugin requires a foreground activity.", null));
      return;
    }

    setCameraDevice(delegate, source);
    if (generalOptions.getAllowMultiple()) {
      int limit = ImagePickerUtils.getLimitFromOption(generalOptions);

      delegate.chooseMultiImageFromGallery(
          options, generalOptions.getUsePhotoPicker(), limit, result);
    } else {
      switch (source.getType()) {
        case GALLERY:
          delegate.chooseImageFromGallery(options, generalOptions.getUsePhotoPicker(), result);
          break;
        case CAMERA:
          delegate.takeImageWithCamera(options, result);
          break;
      }
    }
  }

  @Override
  public void pickMedia(
      @NonNull MediaSelectionOptions mediaSelectionOptions,
      @NonNull GeneralOptions generalOptions,
      @NonNull Result<List<String>> result) {
    ImagePickerDelegate delegate = getImagePickerDelegate();
    if (delegate == null) {
      result.error(
          new FlutterError(
              "no_activity", "image_picker plugin requires a foreground activity.", null));
      return;
    }
    delegate.chooseMediaFromGallery(mediaSelectionOptions, generalOptions, result);
  }

  @Override
  public void pickVideos(
      @NonNull SourceSpecification source,
      @NonNull VideoSelectionOptions options,
      @NonNull GeneralOptions generalOptions,
      @NonNull Result<List<String>> result) {
    ImagePickerDelegate delegate = getImagePickerDelegate();
    if (delegate == null) {
      result.error(
          new FlutterError(
              "no_activity", "image_picker plugin requires a foreground activity.", null));
      return;
    }

    setCameraDevice(delegate, source);
    if (generalOptions.getAllowMultiple()) {
      result.error(new RuntimeException("Multi-video selection is not implemented"));
    } else {
      switch (source.getType()) {
        case GALLERY:
          delegate.chooseVideoFromGallery(options, generalOptions.getUsePhotoPicker(), result);
          break;
        case CAMERA:
          delegate.takeVideoWithCamera(options, result);
          break;
      }
    }
  }

  @Nullable
  @Override
  public CacheRetrievalResult retrieveLostResults() {
    ImagePickerDelegate delegate = getImagePickerDelegate();
    if (delegate == null) {
      throw new FlutterError(
          "no_activity", "image_picker plugin requires a foreground activity.", null);
    }
    return delegate.retrieveLostImage();
  }
}
