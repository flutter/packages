// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.Application;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;
import java.util.HashMap;
import java.util.Map;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class ImagePickerPluginTest {
  private static final int SOURCE_CAMERA = 0;
  private static final int SOURCE_GALLERY = 1;
  private static final String PICK_IMAGE = "pickImage";
  private static final String PICK_MULTI_IMAGE = "pickMultiImage";
  private static final String PICK_VIDEO = "pickVideo";

  @SuppressWarnings("deprecation")
  @Mock
  io.flutter.plugin.common.PluginRegistry.Registrar mockRegistrar;

  @Mock ActivityPluginBinding mockActivityBinding;
  @Mock FlutterPluginBinding mockPluginBinding;

  @Mock Activity mockActivity;
  @Mock Application mockApplication;
  @Mock ImagePickerDelegate mockImagePickerDelegate;
  @Mock MethodChannel.Result mockResult;

  ImagePickerPlugin plugin;

  AutoCloseable mockCloseable;

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);
    when(mockRegistrar.context()).thenReturn(mockApplication);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    when(mockPluginBinding.getApplicationContext()).thenReturn(mockApplication);
    plugin = new ImagePickerPlugin(mockImagePickerDelegate, mockActivity);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void onMethodCall_whenActivityIsNull_finishesWithForegroundActivityRequiredError() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_GALLERY, false);
    ImagePickerPlugin imagePickerPluginWithNullActivity =
        new ImagePickerPlugin(mockImagePickerDelegate, null);
    imagePickerPluginWithNullActivity.onMethodCall(call, mockResult);
    verify(mockResult)
        .error("no_activity", "image_picker plugin requires a foreground activity.", null);
    verifyNoInteractions(mockImagePickerDelegate);
  }

  @Test
  public void onMethodCall_whenCalledWithUnknownMethod_throwsException() {
    IllegalArgumentException e =
        assertThrows(
            IllegalArgumentException.class,
            () -> plugin.onMethodCall(new MethodCall("test", null), mockResult));
    assertEquals(e.getMessage(), "Unknown method test");
    verifyNoInteractions(mockImagePickerDelegate);
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_whenCalledWithUnknownImageSource_throwsException() {
    IllegalArgumentException e =
        assertThrows(
            IllegalArgumentException.class,
            () -> plugin.onMethodCall(buildMethodCall(PICK_IMAGE, -1, false), mockResult));
    assertEquals(e.getMessage(), "Invalid image source: -1");
    verifyNoInteractions(mockImagePickerDelegate);
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_whenSourceIsGallery_invokesChooseImageFromGallery() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_GALLERY, false);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).chooseImageFromGallery(any(), eq(false), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_whenSourceIsGalleryUsingPhotoPicker_invokesChooseImageFromGallery() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_GALLERY, true);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).chooseImageFromGallery(any(), eq(true), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_invokesChooseMultiImageFromGallery() {
    MethodCall call = buildMethodCall(PICK_MULTI_IMAGE);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).chooseMultiImageFromGallery(any(), eq(false), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_usingPhotoPicker_invokesChooseMultiImageFromGallery() {
    MethodCall call = buildMethodCall(PICK_MULTI_IMAGE, SOURCE_GALLERY, true);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).chooseMultiImageFromGallery(any(), eq(true), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_whenSourceIsCamera_invokesTakeImageWithCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA, null);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).takeImageWithCamera(any(), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void onMethodCall_PickingImage_whenSourceIsCamera_invokesTakeImageWithCamera_RearCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA, null);
    HashMap<String, Object> arguments = getArgumentMap(call);
    arguments.put("cameraDevice", 0);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(ImagePickerDelegate.CameraDevice.REAR));
  }

  @Test
  public void
      onMethodCall_PickingImage_whenSourceIsCamera_invokesTakeImageWithCamera_FrontCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA, null);
    HashMap<String, Object> arguments = getArgumentMap(call);
    arguments.put("cameraDevice", 1);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(ImagePickerDelegate.CameraDevice.FRONT));
  }

  @Test
  public void onMethodCall_PickingVideo_whenSourceIsCamera_invokesTakeImageWithCamera_RearCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA, null);
    HashMap<String, Object> arguments = getArgumentMap(call);
    arguments.put("cameraDevice", 0);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(ImagePickerDelegate.CameraDevice.REAR));
  }

  @Test
  public void
      onMethodCall_PickingVideo_whenSourceIsCamera_invokesTakeImageWithCamera_FrontCamera() {
    MethodCall call = buildMethodCall(PICK_IMAGE, SOURCE_CAMERA, null);
    HashMap<String, Object> arguments = getArgumentMap(call);
    arguments.put("cameraDevice", 1);
    plugin.onMethodCall(call, mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(ImagePickerDelegate.CameraDevice.FRONT));
  }

  @Test
  public void onRegister_whenActivityIsNull_shouldNotCrash() {
    when(mockRegistrar.activity()).thenReturn(null);
    ImagePickerPlugin.registerWith((mockRegistrar));
    assertTrue(
        "No exception thrown when ImagePickerPlugin.registerWith ran with activity = null", true);
  }

  @Test
  public void onConstructor_whenContextTypeIsActivity_shouldNotCrash() {
    new ImagePickerPlugin(mockImagePickerDelegate, mockActivity);
    assertTrue(
        "No exception thrown when ImagePickerPlugin() ran with context instanceof Activity", true);
  }

  @Test
  public void constructDelegate_shouldUseInternalCacheDirectory() {
    File mockDirectory = new File("/mockpath");
    when(mockActivity.getCacheDir()).thenReturn(mockDirectory);

    ImagePickerDelegate delegate = plugin.constructDelegate(mockActivity);

    verify(mockActivity, times(1)).getCacheDir();
    assertThat(
        "Delegate uses cache directory for storing camera captures",
        delegate.externalFilesDirectory,
        equalTo(mockDirectory));
  }

  @Test
  public void onDetachedFromActivity_shouldReleaseActivityState() {
    final BinaryMessenger mockBinaryMessenger = mock(BinaryMessenger.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(mockBinaryMessenger);

    final HiddenLifecycleReference mockLifecycleReference = mock(HiddenLifecycleReference.class);
    when(mockActivityBinding.getLifecycle()).thenReturn(mockLifecycleReference);

    final Lifecycle mockLifecycle = mock(Lifecycle.class);
    when(mockLifecycleReference.getLifecycle()).thenReturn(mockLifecycle);

    plugin.onAttachedToEngine(mockPluginBinding);
    plugin.onAttachedToActivity(mockActivityBinding);
    assertNotNull(plugin.getActivityState());

    plugin.onDetachedFromActivity();
    assertNull(plugin.getActivityState());
  }

  private MethodCall buildMethodCall(
      String method, final int source, @Nullable Boolean usePhotoPicker) {
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("source", source);
    if (usePhotoPicker != null) {
      arguments.put("useAndroidPhotoPicker", usePhotoPicker);
    }

    return new MethodCall(method, arguments);
  }

  private MethodCall buildMethodCall(String method) {
    return new MethodCall(method, null);
  }

  @SuppressWarnings("unchecked")
  private HashMap<String, Object> getArgumentMap(MethodCall call) {
    return (HashMap<String, Object>) call.arguments;
  }
}
