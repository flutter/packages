// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.fail;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.widget.FrameLayout;
import androidx.camera.core.Preview;
import androidx.camera.view.PreviewView;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugin.platform.PlatformView;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class PreviewViewTest {
  private static TestProxyApiRegistrar registrarWithAppContext() {
    final TestProxyApiRegistrar registrar = new TestProxyApiRegistrar();
    registrar.setContext(ApplicationProvider.getApplicationContext());
    return registrar;
  }

  @Test
  public void pigeon_defaultConstructor_createsPreviewView() {
    final PigeonApiPreviewView api = registrarWithAppContext().getPigeonApiPreviewView();

    assertNotNull(api.pigeon_defaultConstructor());
  }

  @Test
  public void setImplementationMode_setsTheNativeMode() {
    final PigeonApiPreviewView api = new TestProxyApiRegistrar().getPigeonApiPreviewView();
    final PreviewView instance = mock(PreviewView.class);

    api.setImplementationMode(instance, PreviewViewImplementationMode.PERFORMANCE);
    verify(instance).setImplementationMode(PreviewView.ImplementationMode.PERFORMANCE);

    api.setImplementationMode(instance, PreviewViewImplementationMode.COMPATIBLE);
    verify(instance).setImplementationMode(PreviewView.ImplementationMode.COMPATIBLE);
  }

  @Test
  public void setScaleType_setsTheNativeScaleType() {
    final PigeonApiPreviewView api = new TestProxyApiRegistrar().getPigeonApiPreviewView();
    final PreviewView instance = mock(PreviewView.class);

    api.setScaleType(instance, PreviewViewScaleType.FILL_CENTER);
    verify(instance).setScaleType(PreviewView.ScaleType.FILL_CENTER);

    api.setScaleType(instance, PreviewViewScaleType.FIT_CENTER);
    verify(instance).setScaleType(PreviewView.ScaleType.FIT_CENTER);
  }

  @Test
  public void getSurfaceProvider_returnsTheNativeSurfaceProvider() {
    final PigeonApiPreviewView api = new TestProxyApiRegistrar().getPigeonApiPreviewView();
    final PreviewView instance = mock(PreviewView.class);
    final Preview.SurfaceProvider surfaceProvider = mock(Preview.SurfaceProvider.class);
    when(instance.getSurfaceProvider()).thenReturn(surfaceProvider);

    assertSame(surfaceProvider, api.getSurfaceProvider(instance));
  }

  @Test
  public void factory_createsPlatformViewForInstanceManagerIdentifier() {
    final TestProxyApiRegistrar registrar = registrarWithAppContext();
    final PreviewView previewView = new PreviewView(ApplicationProvider.getApplicationContext());
    final long identifier = registrar.getInstanceManager().addHostCreatedInstance(previewView);
    final PreviewViewFactory factory = new PreviewViewFactory(registrar.getInstanceManager());
    final Context context = mock(Activity.class);

    final PlatformView platformView = factory.create(context, 1, identifier);

    assertSame(previewView, platformView.getView());
  }

  @Test
  public void factory_detachesPreviewViewFromPreviousParent() {
    final TestProxyApiRegistrar registrar = registrarWithAppContext();
    final Context appContext = ApplicationProvider.getApplicationContext();
    final PreviewView previewView = new PreviewView(appContext);
    final FrameLayout oldParent = new FrameLayout(appContext);
    oldParent.addView(previewView);
    final long identifier = registrar.getInstanceManager().addHostCreatedInstance(previewView);
    final PreviewViewFactory factory = new PreviewViewFactory(registrar.getInstanceManager());

    factory.create(appContext, 1, identifier);

    assertNull(previewView.getParent());
  }

  @Test
  public void factory_rejectsUnknownIdentifier() {
    final TestProxyApiRegistrar registrar = registrarWithAppContext();
    final PreviewViewFactory factory = new PreviewViewFactory(registrar.getInstanceManager());

    try {
      factory.create(ApplicationProvider.getApplicationContext(), 1, 12345L);
      fail("Expected an IllegalStateException.");
    } catch (IllegalStateException expected) {
      // Expected.
    }
  }
}
