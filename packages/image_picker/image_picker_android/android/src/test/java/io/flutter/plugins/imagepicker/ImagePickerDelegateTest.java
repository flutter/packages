// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.Manifest;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ClipData;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import androidx.annotation.Nullable;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import org.jetbrains.annotations.NotNull;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
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
  private static final Long MAX_DURATION = 10L;
  private static final Integer IMAGE_QUALITY = 90;
  private static final ImageSelectionOptions DEFAULT_IMAGE_OPTIONS =
      new ImageSelectionOptions(null, null, 100);
  private static final ImageSelectionOptions RESIZE_TRIGGERING_IMAGE_OPTIONS =
      new ImageSelectionOptions(WIDTH, null, 100);
  private static final VideoSelectionOptions DEFAULT_VIDEO_OPTIONS =
      new VideoSelectionOptions(null);
  private static final MediaSelectionOptions DEFAULT_MEDIA_OPTIONS =
      new MediaSelectionOptions(DEFAULT_IMAGE_OPTIONS);

  @Mock Activity mockActivity;
  @Mock ImageResizer mockImageResizer;
  @Mock ImagePickerDelegate.PermissionManager mockPermissionManager;
  @Mock FileUtils mockFileUtils;
  @Mock Intent mockIntent;
  @Mock ImagePickerCache cache;
  @Mock ExecutorService mockExecutor;

  ImagePickerDelegate.FileUriResolver mockFileUriResolver;
  MockedStatic<File> mockStaticFile;

  AutoCloseable mockCloseable;

  File externalDirectory;

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
  public void setUp() throws IOException {
    mockCloseable = MockitoAnnotations.openMocks(this);

    mockStaticFile = Mockito.mockStatic(File.class);
    mockStaticFile
        .when(() -> File.createTempFile(any(), any(), any()))
        .thenReturn(new File("/tmpfile"));

    when(mockActivity.getPackageName()).thenReturn("com.example.test");
    when(mockActivity.getPackageManager()).thenReturn(mock(PackageManager.class));

    TemporaryFolder temporaryFolder = new TemporaryFolder();
    temporaryFolder.create();
    externalDirectory = temporaryFolder.newFolder("image_picker_cache");
    when(mockActivity.getCacheDir()).thenReturn(externalDirectory);

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
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(reply -> null), DEFAULT_IMAGE_OPTIONS, null);

    final Boolean[] callbackCalled = new Boolean[1];
    delegate.chooseImageFromGallery(
        DEFAULT_IMAGE_OPTIONS,
        false,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              assertTrue(reply.isFailure());
              FlutterError error = (FlutterError) reply.exceptionOrNull();
              assertIsAlreadyActiveError(error);
              return null;
            }));

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void chooseMultiImageFromGallery_whenPendingResultExists_finishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(reply -> null), DEFAULT_IMAGE_OPTIONS, null);

    final Boolean[] callbackCalled = new Boolean[1];
    delegate.chooseMultiImageFromGallery(
        DEFAULT_IMAGE_OPTIONS,
        false,
        Integer.MAX_VALUE,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              assertTrue(reply.isFailure());
              FlutterError error = (FlutterError) reply.exceptionOrNull();
              assertIsAlreadyActiveError(error);
              return null;
            }));

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void chooseMediaFromGallery_whenPendingResultExists_finishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(reply -> null), DEFAULT_IMAGE_OPTIONS, null);
    GeneralOptions generalOptions =
        new GeneralOptions(/* allowMultiple */ true, /* usePhotoPicker */ true, null);
    final Boolean[] callbackCalled = new Boolean[1];
    delegate.chooseMediaFromGallery(
        DEFAULT_MEDIA_OPTIONS,
        generalOptions,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              assertTrue(reply.isFailure());
              FlutterError error = (FlutterError) reply.exceptionOrNull();
              assertIsAlreadyActiveError(error);
              return null;
            }));

    assertTrue(callbackCalled[0]);
  }

  @Test
  @Config(sdk = 30)
  public void chooseImageFromGallery_launchesChooseFromGalleryIntent() {
    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseImageFromGallery(
        DEFAULT_IMAGE_OPTIONS, false, ResultCompat.asCompatCallback(reply -> null));

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY));
  }

  @Test
  @Config(minSdk = 33)
  public void chooseImageFromGallery_withPhotoPicker_launchesChooseFromGalleryIntent() {
    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseImageFromGallery(
        DEFAULT_IMAGE_OPTIONS, true, ResultCompat.asCompatCallback(reply -> null));

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY));
  }

  @Test
  @Config(sdk = 30)
  public void chooseMultiImageFromGallery_launchesChooseFromGalleryIntent() {
    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseMultiImageFromGallery(
        DEFAULT_IMAGE_OPTIONS,
        true,
        Integer.MAX_VALUE,
        ResultCompat.asCompatCallback(reply -> null));

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_IMAGE_FROM_GALLERY));
  }

  @Test
  @Config(minSdk = 33)
  public void chooseMultiImageFromGallery_withPhotoPicker_launchesChooseFromGalleryIntent() {
    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseMultiImageFromGallery(
        DEFAULT_IMAGE_OPTIONS,
        false,
        Integer.MAX_VALUE,
        ResultCompat.asCompatCallback(reply -> null));

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class),
            eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_IMAGE_FROM_GALLERY));
  }

  @Test
  @Config(sdk = 30)
  public void chooseVideoFromGallery_launchesChooseFromGalleryIntent() {
    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseVideoFromGallery(
        DEFAULT_VIDEO_OPTIONS, true, ResultCompat.asCompatCallback(reply -> null));

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY));
  }

  @Test
  @Config(minSdk = 33)
  public void chooseVideoFromGallery_withPhotoPicker_launchesChooseFromGalleryIntent() {
    ImagePickerDelegate delegate = createDelegate();
    delegate.chooseVideoFromGallery(
        DEFAULT_VIDEO_OPTIONS, true, ResultCompat.asCompatCallback(reply -> null));

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY));
  }

  @Test
  public void takeImageWithCamera_whenPendingResultExists_finishesWithAlreadyActiveError() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(reply -> null), DEFAULT_IMAGE_OPTIONS, null);

    final Boolean[] callbackCalled = new Boolean[1];
    delegate.takeImageWithCamera(
        DEFAULT_IMAGE_OPTIONS,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              assertTrue(reply.isFailure());
              FlutterError error = (FlutterError) reply.exceptionOrNull();
              assertIsAlreadyActiveError(error);
              return null;
            }));

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void takeImageWithCamera_whenHasNoCameraPermission_requestsForPermission() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(false);
    when(mockPermissionManager.needRequestCameraPermission()).thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(
        DEFAULT_IMAGE_OPTIONS, ResultCompat.asCompatCallback(reply -> null));

    verify(mockPermissionManager)
        .askForPermission(
            Manifest.permission.CAMERA, ImagePickerDelegate.REQUEST_CAMERA_IMAGE_PERMISSION);
  }

  @Test
  public void takeImageWithCamera_whenCameraPermissionNotPresent_requestsForPermission() {
    when(mockPermissionManager.needRequestCameraPermission()).thenReturn(false);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(
        DEFAULT_IMAGE_OPTIONS, ResultCompat.asCompatCallback(reply -> null));

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA));
  }

  @Test
  public void
      takeImageWithCamera_whenHasCameraPermission_andAnActivityCanHandleCameraIntent_launchesTakeWithCameraIntent() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(
        DEFAULT_IMAGE_OPTIONS, ResultCompat.asCompatCallback(reply -> null));

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
    final Boolean[] callbackCalled = new Boolean[1];
    delegate.takeImageWithCamera(
        DEFAULT_IMAGE_OPTIONS,
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              assertTrue(reply.isFailure());
              FlutterError error = (FlutterError) reply.exceptionOrNull();
              assertEquals("no_available_camera", error.getCode());
              assertEquals("No cameras available for taking pictures.", error.getMessage());
              return null;
            }));

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void takeImageWithCamera_writesImageToCacheDirectory() {
    when(mockPermissionManager.isPermissionGranted(Manifest.permission.CAMERA)).thenReturn(true);

    ImagePickerDelegate delegate = createDelegate();
    delegate.takeImageWithCamera(
        DEFAULT_IMAGE_OPTIONS, ResultCompat.asCompatCallback(reply -> null));

    mockStaticFile.verify(
        () -> File.createTempFile(any(), eq(".jpg"), eq(externalDirectory)), times(1));
  }

  @Test
  public void onRequestPermissionsResult_whenCameraPermissionDenied_finishesWithError() {
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isFailure());
                  FlutterError error = (FlutterError) reply.exceptionOrNull();
                  assertEquals("camera_access_denied", error.getCode());
                  assertEquals("The user did not allow camera access.", error.getMessage());
                  return null;
                }),
            DEFAULT_IMAGE_OPTIONS,
            null);

    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_CAMERA_IMAGE_PERMISSION,
        new String[] {Manifest.permission.CAMERA},
        new int[] {PackageManager.PERMISSION_DENIED});

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void
      onRequestTakeVideoPermissionsResult_whenCameraPermissionGranted_launchesTakeVideoWithCameraIntent() {
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(null, null, DEFAULT_VIDEO_OPTIONS);
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
        createDelegateWithPendingCallbackAndOptions(null, DEFAULT_IMAGE_OPTIONS, null);
    delegate.onRequestPermissionsResult(
        ImagePickerDelegate.REQUEST_CAMERA_IMAGE_PERMISSION,
        new String[] {Manifest.permission.CAMERA},
        new int[] {PackageManager.PERMISSION_GRANTED});

    verify(mockActivity)
        .startActivityForResult(
            any(Intent.class), eq(ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA));
  }

  @Test
  public void onActivityResult_whenPickFromGalleryCanceled_finishesWithEmptyList() {
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertTrue(reply.getOrNull().isEmpty());
                  return null;
                }),
            DEFAULT_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_CANCELED, null);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void onActivityResult_whenPickFromGalleryCanceled_storesNothingInCache() {
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    ImagePickerDelegate delegate = createDelegate();

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_CANCELED, null);

    verify(cache, never()).saveResult(any(), any(), any());
  }

  @Test
  public void
      onActivityResult_whenImagePickedFromGallery_andNoResizeNeeded_finishesWithImagePath() {
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertEquals("originalPath", reply.getOrNull().get(0));
                  return null;
                }),
            DEFAULT_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void
      onActivityResult_whenImagePickedFromGallery_nullUriFromGetData_andNoResizeNeeded_finishesWithImagePath() {
    setupMockClipData();

    when(mockIntent.getData()).thenReturn(null);

    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertEquals("originalPath", reply.getOrNull().get(0));
                  return null;
                }),
            DEFAULT_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void
      onActivityResult_whenVideoPickedFromGallery_nullUriFromGetData_finishesWithVideoPath() {
    setupMockClipData();

    when(mockIntent.getData()).thenReturn(null);

    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertEquals("pathFromUri", reply.getOrNull().get(0));
                  return null;
                }),
            null,
            DEFAULT_VIDEO_OPTIONS);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void
      onActivityResult_whenImagePickedFromGallery_nullUri_andNoResizeNeeded_finishesWithNoValidUriError() {
    setupMockClipDataNullUri();

    when(mockIntent.getData()).thenReturn(null);

    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isFailure());
                  FlutterError error = (FlutterError) reply.exceptionOrNull();
                  assertEquals("no_valid_image_uri", error.getCode());
                  assertEquals("Cannot find the selected image.", error.getMessage());
                  return null;
                }),
            DEFAULT_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void onActivityResult_whenVideoPickedFromGallery_nullUri_finishesWithNoValidUriError() {
    setupMockClipDataNullUri();

    when(mockIntent.getData()).thenReturn(null);

    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isFailure());
                  FlutterError error = (FlutterError) reply.exceptionOrNull();
                  assertEquals("no_valid_video_uri", error.getCode());
                  assertEquals("Cannot find the selected video.", error.getMessage());
                  return null;
                }),
            null,
            DEFAULT_VIDEO_OPTIONS);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void onActivityResult_whenImagePickedFromGallery_andNoResizeNeeded_storesImageInCache() {
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
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
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertEquals("scaledPath", reply.getOrNull().get(0));
                  return null;
                }),
            RESIZE_TRIGGERING_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void
      onActivityResult_whenVideoPickedFromGallery_andResizeParametersSupplied_finishesWithFilePath() {
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertEquals("pathFromUri", reply.getOrNull().get(0));
                  return null;
                }),
            RESIZE_TRIGGERING_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void onActivityResult_whenTakeImageWithCameraCanceled_finishesWithEmptyList() {
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertTrue(reply.getOrNull().isEmpty());
                  return null;
                }),
            DEFAULT_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA, Activity.RESULT_CANCELED, null);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void onActivityResult_whenImageTakenWithCamera_andNoResizeNeeded_finishesWithImagePath() {
    when(cache.retrievePendingCameraMediaUriPath()).thenReturn("testString");
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertEquals("originalPath", reply.getOrNull().get(0));
                  return null;
                }),
            DEFAULT_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void
      onActivityResult_whenImageTakenWithCamera_andResizeNeeded_finishesWithScaledImagePath() {
    when(cache.retrievePendingCameraMediaUriPath()).thenReturn("testString");
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertEquals("scaledPath", reply.getOrNull().get(0));
                  return null;
                }),
            RESIZE_TRIGGERING_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void
      onActivityResult_whenVideoTakenWithCamera_andResizeParametersSupplied_finishesWithFilePath() {
    when(cache.retrievePendingCameraMediaUriPath()).thenReturn("testString");
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertEquals("pathFromUri", reply.getOrNull().get(0));
                  return null;
                }),
            RESIZE_TRIGGERING_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void
      onActivityResult_whenVideoTakenWithCamera_andMaxDurationParametersSupplied_finishesWithFilePath() {
    when(cache.retrievePendingCameraMediaUriPath()).thenReturn("testString");
    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isSuccess());
                  assertEquals("pathFromUri", reply.getOrNull().get(0));
                  return null;
                }),
            null,
            new VideoSelectionOptions(MAX_DURATION));

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void onActivityResult_whenImagePickedFromGallery_returnsTrue() {
    ImagePickerDelegate delegate = createDelegate();

    boolean isHandled =
        delegate.onActivityResult(
            ImagePickerDelegate.REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY,
            Activity.RESULT_OK,
            mockIntent);

    assertTrue(isHandled);
  }

  @Test
  public void onActivityResult_whenMultipleImagesPickedFromGallery_returnsTrue() {
    ImagePickerDelegate delegate = createDelegate();

    boolean isHandled =
        delegate.onActivityResult(
            ImagePickerDelegate.REQUEST_CODE_CHOOSE_MULTI_IMAGE_FROM_GALLERY,
            Activity.RESULT_OK,
            mockIntent);

    assertTrue(isHandled);
  }

  @Test
  public void onActivityResult_whenMediaPickedFromGallery_returnsTrue() {
    ImagePickerDelegate delegate = createDelegate();

    boolean isHandled =
        delegate.onActivityResult(
            ImagePickerDelegate.REQUEST_CODE_CHOOSE_MEDIA_FROM_GALLERY,
            Activity.RESULT_OK,
            mockIntent);

    assertTrue(isHandled);
  }

  @Test
  public void onActivityResult_whenVideoPickerFromGallery_returnsTrue() {
    ImagePickerDelegate delegate = createDelegate();

    boolean isHandled =
        delegate.onActivityResult(
            ImagePickerDelegate.REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY,
            Activity.RESULT_OK,
            mockIntent);

    assertTrue(isHandled);
  }

  @Test
  public void onActivityResult_whenImageTakenWithCamera_returnsTrue() {
    ImagePickerDelegate delegate = createDelegate();

    boolean isHandled =
        delegate.onActivityResult(
            ImagePickerDelegate.REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA,
            Activity.RESULT_OK,
            mockIntent);

    assertTrue(isHandled);
  }

  @Test
  public void onActivityResult_whenVideoTakenWithCamera_returnsTrue() {
    ImagePickerDelegate delegate = createDelegate();

    boolean isHandled =
        delegate.onActivityResult(
            ImagePickerDelegate.REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA,
            Activity.RESULT_OK,
            mockIntent);

    assertTrue(isHandled);
  }

  @Test
  public void onActivityResult_withUnknownRequest_returnsFalse() {
    ImagePickerDelegate delegate = createDelegate();

    boolean isHandled = delegate.onActivityResult(314, Activity.RESULT_OK, mockIntent);

    assertFalse(isHandled);
  }

  @Test
  public void onActivityResult_whenImagePickedFromGallery_finishesWithErrorIfClipDataIsNull() {
    when(mockIntent.getData()).thenReturn(null);
    when(mockIntent.getClipData()).thenReturn(null);

    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isFailure());
                  FlutterError error = (FlutterError) reply.exceptionOrNull();
                  assertEquals("no_valid_media_uri", error.getCode());
                  assertEquals("Cannot find the selected media.", error.getMessage());
                  return null;
                }),
            DEFAULT_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_MEDIA_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void onActivityResult_whenImagePickedFromGallery_finishesWithErrorIfClipDataUriIsNull() {
    setupMockClipDataNullUri();
    when(mockIntent.getData()).thenReturn(null);
    when(mockIntent.getClipData()).thenReturn(null);

    Mockito.doAnswer(
            invocation -> {
              ((Runnable) invocation.getArgument(0)).run();
              return null;
            })
        .when(mockExecutor)
        .execute(any(Runnable.class));
    final Boolean[] callbackCalled = new Boolean[1];
    ImagePickerDelegate delegate =
        createDelegateWithPendingCallbackAndOptions(
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertTrue(reply.isFailure());
                  FlutterError error = (FlutterError) reply.exceptionOrNull();
                  assertEquals("no_valid_media_uri", error.getCode());
                  assertEquals("Cannot find the selected media.", error.getMessage());
                  return null;
                }),
            DEFAULT_IMAGE_OPTIONS,
            null);

    delegate.onActivityResult(
        ImagePickerDelegate.REQUEST_CODE_CHOOSE_MEDIA_FROM_GALLERY, Activity.RESULT_OK, mockIntent);

    assertTrue(callbackCalled[0]);
  }

  private ImagePickerDelegate createDelegate() {
    return new ImagePickerDelegate(
        mockActivity,
        mockImageResizer,
        null,
        null,
        null,
        cache,
        mockPermissionManager,
        mockFileUriResolver,
        mockFileUtils,
        mockExecutor);
  }

  private ImagePickerDelegate createDelegateWithPendingCallbackAndOptions(
      @Nullable
          Function1<
                  ? super @NotNull Result<? extends @NotNull List<@NotNull String>>, @NotNull Unit>
              callback,
      @Nullable ImageSelectionOptions imageOptions,
      @Nullable VideoSelectionOptions videoOptions) {
    return new ImagePickerDelegate(
        mockActivity,
        mockImageResizer,
        imageOptions,
        videoOptions,
        callback,
        cache,
        mockPermissionManager,
        mockFileUriResolver,
        mockFileUtils,
        mockExecutor);
  }

  private void assertIsAlreadyActiveError(FlutterError error) {
    assertEquals("already_active", error.getCode());
    assertEquals("Image picker is already active", error.getMessage());
  }

  private void setupMockClipData() {
    ClipData mockClipData = mock(ClipData.class);
    ClipData.Item mockItem = mock(ClipData.Item.class);
    Uri mockUri = mock(Uri.class);
    when(mockItem.getUri()).thenReturn(mockUri);
    when(mockClipData.getItemCount()).thenReturn(1);
    when(mockClipData.getItemAt(0)).thenReturn(mockItem);
    when(mockIntent.getClipData()).thenReturn(mockClipData);
  }

  private void setupMockClipDataNullUri() {
    ClipData mockClipData = mock(ClipData.class);
    ClipData.Item mockItem = mock(ClipData.Item.class);
    when(mockItem.getUri()).thenReturn(null);
    when(mockClipData.getItemCount()).thenReturn(1);
    when(mockClipData.getItemAt(0)).thenReturn(mockItem);
    when(mockIntent.getClipData()).thenReturn(mockClipData);
  }
}
