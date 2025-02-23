//// Copyright 2013 The Flutter Authors. All rights reserved.
//// Use of this source code is governed by a BSD-style license that can be
//// found in the LICENSE file.
//
//package io.flutter.plugins.camerax
//
//import androidx.lifecycle.Observer<*>
//import org.junit.Test;
//import static org.junit.Assert.assertEquals;
//import static org.junit.Assert.assertTrue;
//import org.mockito.Mockito;
//import org.mockito.Mockito.any;
//import java.util.HashMap;
//import static org.mockito.Mockito.eq;
//import static org.mockito.Mockito.mock;
//import org.mockito.Mockito.verify;
//import static org.mockito.Mockito.when;
//
//public class ObserverProxyApiTest {
//  @Test
//  public void pigeon_defaultConstructor() {
//    final PigeonApiObserver api = new TestProxyApiRegistrar().getPigeonApiObserver();
//
//    assertTrue(api.pigeon_defaultConstructor() instanceof ObserverProxyApi.ObserverImpl);
//  }
//
//  @Test
//  public void onChanged() {
//    final ObserverProxyApi mockApi = mock(ObserverProxyApi.class);
//    when(mockApi.pigeonRegistrar).thenReturn(new TestProxyApiRegistrar());
//
//    final ObserverImpl instance = new ObserverImpl(mockApi);
//    final Any value = -1;
//    instance.onChanged(value);
//
//    verify(mockApi).onChanged(eq(instance), eq(value), any());
//  }
//}
