// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.test.core.app.ApplicationProvider;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.UserChoiceBillingListener;
import com.android.billingclient.api.UserChoiceDetails;
import io.flutter.plugins.inapppurchase.Messages.InAppPurchaseCallbackApi;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingChoiceMode;
import io.flutter.plugins.inapppurchase.Messages.PlatformUserChoiceDetails;
import java.util.Collections;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class BillingClientFactoryImplTest {

  private AutoCloseable openMocks;
  BillingClientFactoryImpl factory;
  @Mock InAppPurchaseCallbackApi mockCallbackApi;
  Context context;

  @Before
  public void setUp() {
    openMocks = MockitoAnnotations.openMocks(this);
    // Context must be a "real/robolectric" context since the implementation of billing client
    // calls methods on context.
    context = ApplicationProvider.getApplicationContext();
    factory = spy(new BillingClientFactoryImpl());
  }

  @Test
  public void playBillingOnly() {
    // No logic to verify just ensure creation works.
    BillingClient client =
        factory.createBillingClient(
            context, mockCallbackApi, PlatformBillingChoiceMode.PLAY_BILLING_ONLY);
    assertNotNull(client);
  }

  @Test
  public void alternativeBillingOnly() {
    // No logic to verify just ensure creation works.
    BillingClient client =
        factory.createBillingClient(
            context, mockCallbackApi, PlatformBillingChoiceMode.ALTERNATIVE_BILLING_ONLY);
    assertNotNull(client);
  }

  @Test
  public void userChoiceBilling() {
    final UserChoiceBillingListener listener =
        factory.createUserChoiceBillingListener(mockCallbackApi);
    doReturn(listener)
        .when(factory)
        .createUserChoiceBillingListener(any(InAppPurchaseCallbackApi.class));

    final BillingClient billingClient =
        factory.createBillingClient(
            context, mockCallbackApi, PlatformBillingChoiceMode.USER_CHOICE_BILLING);

    UserChoiceDetails details = mock(UserChoiceDetails.class);
    final String externalTransactionToken = "someLongTokenId1234";
    final String originalTransactionId = "originalTransactionId123456";
    when(details.getExternalTransactionToken()).thenReturn(externalTransactionToken);
    when(details.getOriginalExternalTransactionId()).thenReturn(originalTransactionId);
    when(details.getProducts()).thenReturn(Collections.emptyList());
    listener.userSelectedAlternativeBilling(details);

    ArgumentCaptor<PlatformUserChoiceDetails> callbackCaptor =
        ArgumentCaptor.forClass(PlatformUserChoiceDetails.class);
    verify(mockCallbackApi, times(1))
        .userSelectedalternativeBilling(callbackCaptor.capture(), any());
    assertEquals(callbackCaptor.getValue().getExternalTransactionToken(), externalTransactionToken);
    assertEquals(
        callbackCaptor.getValue().getOriginalExternalTransactionId(), originalTransactionId);
    assertTrue(callbackCaptor.getValue().getProducts().isEmpty());
  }

  @After
  public void tearDown() throws Exception {
    openMocks.close();
  }
}
