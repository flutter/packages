// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.Application;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.imagepicker.Messages.FlutterError;
import io.flutter.plugins.imagepicker.Messages.GeneralOptions;
import io.flutter.plugins.imagepicker.Messages.ImageSelectionOptions;
import io.flutter.plugins.imagepicker.Messages.MediaSelectionOptions;
import io.flutter.plugins.imagepicker.Messages.SourceSpecification;
import io.flutter.plugins.imagepicker.Messages.VideoSelectionOptions;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class ImagePickerPluginTest {
  private static final ImageSelectionOptions DEFAULT_IMAGE_OPTIONS =
      new ImageSelectionOptions.Builder().setQuality((long) 100).build();
  private static final VideoSelectionOptions DEFAULT_VIDEO_OPTIONS =
      new VideoSelectionOptions.Builder().build();
  private static final MediaSelectionOptions DEFAULT_MEDIA_OPTIONS =
      new MediaSelectionOptions.Builder().setImageSelectionOptions(DEFAULT_IMAGE_OPTIONS).build();
  private static final GeneralOptions GENERAL_OPTIONS_ALLOW_MULTIPLE_USE_PHOTO_PICKER =
      new GeneralOptions.Builder().setUsePhotoPicker(true).setAllowMultiple(true).build();
  private static final GeneralOptions GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_USE_PHOTO_PICKER =
      new GeneralOptions.Builder().setUsePhotoPicker(true).setAllowMultiple(false).build();
  private static final GeneralOptions GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER =
      new GeneralOptions.Builder().setUsePhotoPicker(false).setAllowMultiple(false).build();
  private static final GeneralOptions GENERAL_OPTIONS_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER =
      new GeneralOptions.Builder().setUsePhotoPicker(false).setAllowMultiple(true).build();
  private static final GeneralOptions
      GENERAL_OPTIONS_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER_WITH_LIMIT =
          new GeneralOptions.Builder()
              .setUsePhotoPicker(false)
              .setAllowMultiple(true)
              .setLimit((long) 5)
              .build();
  private static final GeneralOptions GENERAL_OPTIONS_ALLOW_MULTIPLE_USE_PHOTO_PICKER_WITH_LIMIT =
      new GeneralOptions.Builder()
          .setUsePhotoPicker(true)
          .setAllowMultiple(true)
          .setLimit((long) 5)
          .build();
  private static final SourceSpecification SOURCE_GALLERY =
      new SourceSpecification.Builder().setType(Messages.SourceType.GALLERY).build();
  private static final SourceSpecification SOURCE_CAMERA_FRONT =
      new SourceSpecification.Builder()
          .setType(Messages.SourceType.CAMERA)
          .setCamera(Messages.SourceCamera.FRONT)
          .build();
  private static final SourceSpecification SOURCE_CAMERA_REAR =
      new SourceSpecification.Builder()
          .setType(Messages.SourceType.CAMERA)
          .setCamera(Messages.SourceCamera.REAR)
          .build();

  @Mock ActivityPluginBinding mockActivityBinding;
  @Mock FlutterPluginBinding mockPluginBinding;

  @Mock Activity mockActivity;
  @Mock Application mockApplication;
  @Mock ImagePickerDelegate mockImagePickerDelegate;
  @Mock Messages.Result<List<String>> mockResult;

  ImagePickerPlugin plugin;

  AutoCloseable mockCloseable;

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    when(mockPluginBinding.getApplicationContext()).thenReturn(mockApplication);
    plugin = new ImagePickerPlugin(mockImagePickerDelegate, mockActivity);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void pickImages_whenActivityIsNull_finishesWithForegroundActivityRequiredError() {
    ImagePickerPlugin imagePickerPluginWithNullActivity =
        new ImagePickerPlugin(mockImagePickerDelegate, null);
    imagePickerPluginWithNullActivity.pickImages(
        SOURCE_GALLERY,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_ALLOW_MULTIPLE_USE_PHOTO_PICKER,
        mockResult);

    ArgumentCaptor<FlutterError> errorCaptor = ArgumentCaptor.forClass(FlutterError.class);
    verify(mockResult).error(errorCaptor.capture());
    assertEquals("no_activity", errorCaptor.getValue().code);
    assertEquals(
        "image_picker plugin requires a foreground activity.", errorCaptor.getValue().getMessage());
    verifyNoInteractions(mockImagePickerDelegate);
  }

  @Test
  public void pickVideos_whenActivityIsNull_finishesWithForegroundActivityRequiredError() {
    ImagePickerPlugin imagePickerPluginWithNullActivity =
        new ImagePickerPlugin(mockImagePickerDelegate, null);
    imagePickerPluginWithNullActivity.pickVideos(
        SOURCE_CAMERA_REAR,
        DEFAULT_VIDEO_OPTIONS,
        GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER,
        mockResult);

    ArgumentCaptor<FlutterError> errorCaptor = ArgumentCaptor.forClass(FlutterError.class);
    verify(mockResult).error(errorCaptor.capture());
    assertEquals("no_activity", errorCaptor.getValue().code);
    assertEquals(
        "image_picker plugin requires a foreground activity.", errorCaptor.getValue().getMessage());
    verifyNoInteractions(mockImagePickerDelegate);
  }

  @Test
  public void retrieveLostResults_whenActivityIsNull_finishesWithForegroundActivityRequiredError() {
    ImagePickerPlugin imagePickerPluginWithNullActivity =
        new ImagePickerPlugin(mockImagePickerDelegate, null);
    FlutterError error =
        assertThrows(FlutterError.class, imagePickerPluginWithNullActivity::retrieveLostResults);
    assertEquals("image_picker plugin requires a foreground activity.", error.getMessage());
    assertEquals("no_activity", error.code);
    verifyNoInteractions(mockImagePickerDelegate);
  }

  @Test
  public void pickImages_whenSourceIsGallery_invokesChooseImageFromGallery() {
    plugin.pickImages(
        SOURCE_GALLERY,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate).chooseImageFromGallery(any(), eq(false), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void pickImages_whenSourceIsGalleryUsingPhotoPicker_invokesChooseImageFromGallery() {
    plugin.pickImages(
        SOURCE_GALLERY,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate).chooseImageFromGallery(any(), eq(true), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void pickImages_invokesChooseMultiImageFromGallery() {
    plugin.pickImages(
        SOURCE_GALLERY,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate)
        .chooseMultiImageFromGallery(any(), eq(false), eq(Integer.MAX_VALUE), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void pickImages_usingPhotoPicker_invokesChooseMultiImageFromGallery() {
    plugin.pickImages(
        SOURCE_GALLERY,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_ALLOW_MULTIPLE_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate)
        .chooseMultiImageFromGallery(any(), eq(true), eq(Integer.MAX_VALUE), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void pickImages_usingPhotoPicker_withLimit5_invokesChooseMultiImageFromGallery() {
    plugin.pickImages(
        SOURCE_GALLERY,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_ALLOW_MULTIPLE_USE_PHOTO_PICKER_WITH_LIMIT,
        mockResult);
    verify(mockImagePickerDelegate).chooseMultiImageFromGallery(any(), eq(true), eq(5), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void pickImages_withLimit5_invokesChooseMultiImageFromGallery() {
    plugin.pickImages(
        SOURCE_GALLERY,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER_WITH_LIMIT,
        mockResult);
    verify(mockImagePickerDelegate).chooseMultiImageFromGallery(any(), eq(false), eq(5), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void pickMedia_invokesChooseMediaFromGallery() {
    MediaSelectionOptions mediaSelectionOptions =
        new MediaSelectionOptions.Builder().setImageSelectionOptions(DEFAULT_IMAGE_OPTIONS).build();
    plugin.pickMedia(
        mediaSelectionOptions,
        GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate)
        .chooseMediaFromGallery(
            eq(mediaSelectionOptions),
            eq(GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER),
            any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void pickMedia_usingPhotoPicker_invokesChooseMediaFromGallery() {
    MediaSelectionOptions mediaSelectionOptions =
        new MediaSelectionOptions.Builder().setImageSelectionOptions(DEFAULT_IMAGE_OPTIONS).build();
    plugin.pickMedia(
        mediaSelectionOptions, GENERAL_OPTIONS_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER, mockResult);
    verify(mockImagePickerDelegate)
        .chooseMediaFromGallery(
            eq(mediaSelectionOptions),
            eq(GENERAL_OPTIONS_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER),
            any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void pickImages_whenSourceIsCamera_invokesTakeImageWithCamera() {
    plugin.pickImages(
        SOURCE_CAMERA_REAR,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate).takeImageWithCamera(any(), any());
    verifyNoInteractions(mockResult);
  }

  @Test
  public void pickImages_whenSourceIsCamera_invokesTakeImageWithCamera_RearCamera() {
    plugin.pickImages(
        SOURCE_CAMERA_REAR,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(ImagePickerDelegate.CameraDevice.REAR));
  }

  @Test
  public void pickImages_whenSourceIsCamera_invokesTakeImageWithCamera_FrontCamera() {
    plugin.pickImages(
        SOURCE_CAMERA_FRONT,
        DEFAULT_IMAGE_OPTIONS,
        GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(ImagePickerDelegate.CameraDevice.FRONT));
  }

  @Test
  public void pickVideos_whenSourceIsCamera_invokesTakeImageWithCamera_RearCamera() {
    plugin.pickVideos(
        SOURCE_CAMERA_REAR,
        DEFAULT_VIDEO_OPTIONS,
        GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(ImagePickerDelegate.CameraDevice.REAR));
  }

  @Test
  public void pickVideos_whenSourceIsCamera_invokesTakeImageWithCamera_FrontCamera() {
    plugin.pickVideos(
        SOURCE_CAMERA_FRONT,
        DEFAULT_VIDEO_OPTIONS,
        GENERAL_OPTIONS_DONT_ALLOW_MULTIPLE_DONT_USE_PHOTO_PICKER,
        mockResult);
    verify(mockImagePickerDelegate).setCameraDevice(eq(ImagePickerDelegate.CameraDevice.FRONT));
  }

  @Test
  public void onConstructor_whenContextTypeIsActivity_shouldNotCrash() {
    new ImagePickerPlugin(mockImagePickerDelegate, mockActivity);
    assertTrue(
        "No exception thrown when ImagePickerPlugin() ran with context instanceof Activity", true);
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
}
