// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.Manifest;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
public class ImagePickerDelegateTest {
  private static final Double WIDTH = 10.0;
  private static final Double HEIGHT = 10.0;
  private static final int MAX_DURATION = 10;
  private static final Integer IMAGE_QUALITY = 90;
  private static final ImageOutputOptions DEFAULT_IMAGE_OPTIONS =
      new ImageOutputOptions(null, null, null);
  private static final VideoOptions DEFAULT_VIDEO_OPTIONS = new VideoOptions(null);

  @Mock Activity mockActivity;
  @Mock ImageResizer mockImageResizer;
  @Mock MethodChannel.Result mockResult;
  @Mock ImagePickerDelegate.PermissionManager mockPermissionManager;
  @Mock FileUtils mockFileUtils;
  @Mock Intent mockIntent;
  @Mock ImagePickerCache cache;

  ImagePickerDelegate.FileUriResolver mockFileUriResolver;
  MockedStatic<File> mockStaticFile;

  AutoCloseable mockCloseable;

  private static class MockFileUriResolver implements ImagePickerDelegate.FileUriResolver {
    @Override
    public Uri resolveFileProviderUriForFile(String fileProviderName, File imageFile) {
      return null;
    }

    @Override
    public void getFullImagePath(Uri imageUri, ImagePickerDelegate.OnPathReadyListener listener) {
      listener.onPathReady("pathFromUri");
    }
  }

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);

    mockStaticFile = Mockito.mockStatic(File.class);
    mockStaticFile
        .when(() -> File.createTempFile(any(), any(), any()))
        .thenReturn(new File("/tmpfile"));

    when(mockActivity.getPackageName()).thenReturn("com.example.test");
    when(mockActivity.getPackageManager()).thenReturn(mock(PackageManager.class));

    when(mockFileUtils.getPathFromUri(any(Context.class), any(Uri.class)))
        .thenReturn("pathFromUri");

    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", null, null, 100))
        .thenReturn("originalPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", null, null, IMAGE_QUALITY))
        .thenReturn("originalPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", WIDTH, HEIGHT, 100))
        .thenReturn("scaledPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", WIDTH, null, 100))
        .thenReturn("scaledPath");
    when(mockImageResizer.resizeImageIfNeeded("pathFromUri", null, HEIGHT, 100))
        .thenReturn("scaledPath");

    mockFileUriResolver = new MockFileUriResolver();

    Uri mockUri = mock(Uri.class);
    when(mockIntent.getData()).thenReturn(mockUri);
  }

  @After
  public void tearDown() throws Exception {
    mockStaticFile.close();
    mockCloseable.close();
  }

  @Test
  public void whenConstructed_setsCorrectFileProviderName() {
    ImagePickerDelegate delegate = createDelegate();
    assertThat(delegate.fileProviderName, equalTo("com.example.test.flutter.image_provider"));
  }

  @Test
  public void chooseImageFromGallery_whenPendingResultExists_finishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(DEFAULT_IMAGE_OPTIONS, null);

    delegate.chooseImageFromGallery(new ImageOutputOptions(null, null, null), false, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void chooseMultiImageFromGallery_whenPendingResultExists_finishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(DEFAULT_IMAGE_OPTIONS, null);

    delegate.chooseMultiImageFromGallery(
        new ImageOutputOptions(null, null, null), false, mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  @Config(sdk = 30)
  public void chooseImageFromGallery_launchesChooseFromGalleryIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE))
        .thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseImageFromGallery(new ImageOutputOptions(null, null, null), false, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY));
  }

  @Test
  @Config(minSdk = 33)
  public void chooseImageFromGallery_WithPhotoPicker_launchesChooseFromGalleryIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE))
        .thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseImageFromGallery(new ImageOutputOptions(null, null, null), true, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY));
  }

  @Test
  @Config(sdk = 30)
  public void chooseMultiImageFromGallery_launchesChooseFromGalleryIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE))
        .thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseMultiImageFromGallery(
        new ImageOutputOptions(null, null, null), true, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_IMAGE_FROM_GALLERY));
  }

  @Test
  @Config(minSdk = 33)
  public void chooseMultiImageFromGallery_WithPhotoPicker_launchesChooseFromGalleryIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE))
        .thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseMultiImageFromGallery(
        new ImageOutputOptions(null, null, null), false, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_IMAGE_FROM_GALLERY));
  }

  @Test
  @Config(sdk = 30)
  public void chooseVideoFromGallery_launchesChooseFromGalleryIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE))
        .thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseVideoFromGallery(new VideoOptions(null), true, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY));
  }

  @Test
  @Config(minSdk = 33)
  public void chooseVideoFromGallery_WithPhotoPicker_launchesChooseFromGalleryIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE))
        .thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseVideoFromGallery(new VideoOptions(null), true, mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY));
  }

  @Test
  public void takeImageWithCamera_whenPendingResultExists_finishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(DEFAULT_IMAGE_OPTIONS, null);

    delegate.takeImageWithCamera(new ImageOutputOptions(null, null, null), mockResult);

    verifyFinishedWithAlreadyActiveError();
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void takeImageWithCamera_whenHasNoCameraPermission_RequestsForPermission() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(false);
    when(mockPermissionManager.needRequestCameraPermission()).thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(new ImageOutputOptions(null, null, null), mockResult);

    verify(mockPermissionManager)
        .askForPermission(
            Manifest.permission.CAMERA, ImagePickerDelegate.REQUEST_CAMERA_IMAGE_PERMISSION);
  }

  @Test
  public void takeImageWithCamera_whenCameraPermissionNotPresent_RequestsForPermission() {
    when(mockPermissionManager.needRequestCameraPermission()).thenReturn(false);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(new ImageOutputOptions(null, null, null), mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA));
  }

  @Test
  public void
      takeImageWithCamera_whenHasCameraPermission_andAnActivityCanHandleCameraIntent_launchesTakeWithCameraIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(new ImageOutputOptions(null, null, null), mockResult);

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA));
  }

  @Test
  public void
      takeImageWithCamera_whenHasCameraPermission_andNoActivityToHandleCameraIntent_finishesWithNoCamerasAvailableError() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(true);
    doThrow(ActivityNotFoundException.class)
        .when(mockActivity)
        .startActivityForResult(any(Intent.class), anyInt());
    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(new ImageOutputOptions(null, null, null), mockResult);

    verify(mockResult)
        .error("no_available_camera", "No cameras available for taking pictures.", null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void takeImageWithCamera_writesImageToCacheDirectory() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(new ImageOutputOptions(null, null, null), mockResult);

    mockStaticFile.verify(
        () -> File.createTempFile(any(), eq(".jpg"), eq(new File("/image_picker_cache"))),
        times(1));
  }

  @Test
  public void onRequestPermissionsResult_whenCameraPermissionDenied_finishesWithError() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(DEFAULT_IMAGE_OPTIONS, null);

    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_CAMERA_IMAGE_PERMISSION,
        new String[] {Manifest.permission.CAMERA},
        new int[] {PackageManager.PERMISSION_DENIED});

    verify(mockResult).error("camera_access_denied", "The user did not allow camera access.", null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onRequestTakeVideoPermissionsResult_whenCameraPermissionGranted_launchesTakeVideoWithCameraIntent() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(null, DEFAULT_VIDEO_OPTIONS);
    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_CAMERA_VIDEO_PERMISSION,
        new String[] {Manifest.permission.CAMERA},
        new int[] {PackageManager.PERMISSION_GRANTED});

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA));
  }

  @Test
  public void
      onRequestTakeImagePermissionsResult_whenCameraPermissionGranted_launchesTakeWithCameraIntent() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(DEFAULT_IMAGE_OPTIONS, null);
    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_CAMERA_IMAGE_PERMISSION,
        new String[] {Manifest.permission.CAMERA},
        new int[] {PackageManager.PERMISSION_GRANTED});

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA));
  }

  @Test
  public void onActivityResult_whenPickFromGalleryCanceled_finishesWithNull() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(DEFAULT_IMAGE_OPTIONS, null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_CANCELED, null);

    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_whenPickFromGalleryCanceled_storesNothingInCache() {
    ImagePickerDelegate delegate = createDelegate();

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_CANCELED, null);

    verify(cache, never()).saveResult(any(), any(), any());
  }

  @Test
  public void
      onActivityResult_whenImagePickedFromGallery_andNoResizeNeeded_finishesWithImagePath() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(DEFAULT_IMAGE_OPTIONS, null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("originalPath");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_whenImagePickedFromGallery_andNoResizeNeeded_StoresImageInCache() {
    ImagePickerDelegate delegate = createDelegate();

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    @SuppressWarnings("unchecked")
    ArgumentCaptor<ArrayList<String>> pathListCapture = ArgumentCaptor.forClass(ArrayList.class);
    verify(cache, times(1)).saveResult(pathListCapture.capture(), any(), any());
    assertEquals("pathFromUri", pathListCapture.getValue().get(0));
  }

  @Test
  public void
      onActivityResult_whenImagePickedFromGallery_andResizeNeeded_finishesWithScaledImagePath() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(new ImageOutputOptions(WIDTH, null, null), null);
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("scaledPath");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_whenVideoPickedFromGallery_andResizeParametersSupplied_finishesWithFilePath() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(new ImageOutputOptions(WIDTH, null, null), null);
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("pathFromUri");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_whenTakeImageWithCameraCanceled_finishesWithNull() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(DEFAULT_IMAGE_OPTIONS, null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA, Activity.RESULT_CANCELED, null);

    verify(mockResult).success(null);
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void onActivityResult_whenImageTakenWithCamera_andNoResizeNeeded_finishesWithImagePath() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(DEFAULT_IMAGE_OPTIONS, null);
    when(cache.retrievePendingCameraMediaUriPath()).thenReturn("testString");

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("originalPath");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_whenImageTakenWithCamera_andResizeNeeded_finishesWithScaledImagePath() {
    when(cache.retrievePendingCameraMediaUriPath()).thenReturn("testString");

    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(new ImageOutputOptions(WIDTH, null, null), null);
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("scaledPath");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_whenVideoTakenWithCamera_andResizeParametersSupplied_finishesWithFilePath() {
    when(cache.retrievePendingCameraMediaUriPath()).thenReturn("testString");

    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(new ImageOutputOptions(WIDTH, null, null), null);
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("pathFromUri");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      onActivityResult_whenVideoTakenWithCamera_andMaxDurationParametersSupplied_finishesWithFilePath() {
    when(cache.retrievePendingCameraMediaUriPath()).thenReturn("testString");

    ImagePickerDelegate delegate =
        createDelegateWithPendingResultAndOptions(null, new VideoOptions(MAX_DURATION));
    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    verify(mockResult).success("pathFromUri");
    verifyNoMoreInteractions(mockResult);
  }

  @Test
  public void
      retrieveLostImage_ShouldBeAbleToReturnLastItemFromResultMapWhenSingleFileIsRecovered() {
    Map<String, Object> resultMap = new HashMap<>();
    ArrayList<String> pathList = new ArrayList<>();
    pathList.add("/example/first_item");
    pathList.add("/example/last_item");
    resultMap.put("pathList", pathList);

    when(mockImageResizer.resizeImageIfNeeded(pathList.get(0), null, null, 100))
        .thenReturn(pathList.get(0));
    when(mockImageResizer.resizeImageIfNeeded(pathList.get(1), null, null, 100))
        .thenReturn(pathList.get(1));
    when(cache.getCacheMap()).thenReturn(resultMap);

    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    ImagePickerDelegate mockDelegate = createDelegate();

    @SuppressWarnings("unchecked")
    ArgumentCaptor<Map<String, Object>> valueCapture = ArgumentCaptor.forClass(Map.class);

    doNothing().when(mockResult).success(valueCapture.capture());

    mockDelegate.retrieveLostImage(mockResult);

    assertEquals("/example/last_item", valueCapture.getValue().get("path"));
  }

  private ImagePickerDelegate createDelegate() {
    return new ImagePickerDelegate(
        mockActivity,
        new File("/image_picker_cache"),
        mockImageResizer,
        null,
        null,
        null,
        cache,
        mockPermissionManager,
        mockFileUriResolver,
        mockFileUtils);
  }

  private ImagePickerDelegate createDelegateWithPendingResultAndOptions(
      @Nullable ImageOutputOptions imageOptions, @Nullable VideoOptions videoOptions) {
    return new ImagePickerDelegate(
        mockActivity,
        new File("/image_picker_cache"),
        mockImageResizer,
        imageOptions,
        videoOptions,
        mockResult,
        cache,
        mockPermissionManager,
        mockFileUriResolver,
        mockFileUtils);
  }

  private void verifyFinishedWithAlreadyActiveError() {
    verify(mockResult).error("already_active", "Image picker is already active", null);
  }
}
