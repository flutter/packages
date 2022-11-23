// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import java.util.ArrayList;
import java.util.Arrays;
import org.junit.Test;

public class NullFieldsTest {
  @Test
  public void builderWithValues() {
    NullFields.NullFieldsSearchRequest request =
        new NullFields.NullFieldsSearchRequest.Builder()
            .setQuery("hello")
            .setIdentifier(1L)
            .build();

    NullFields.NullFieldsSearchReply reply =
        new NullFields.NullFieldsSearchReply.Builder()
            .setResult("result")
            .setError("error")
            .setIndices(Arrays.asList(1L, 2L, 3L))
            .setRequest(request)
            .setType(NullFields.NullFieldsSearchReplyType.SUCCESS)
            .build();

    assertEquals(reply.getResult(), "result");
    assertEquals(reply.getError(), "error");
    assertEquals(reply.getIndices(), Arrays.asList(1L, 2L, 3L));
    assertEquals(reply.getRequest().getQuery(), "hello");
    assertEquals(reply.getType(), NullFields.NullFieldsSearchReplyType.SUCCESS);
  }

  @Test
  public void builderRequestWithNulls() {
    NullFields.NullFieldsSearchRequest request =
        new NullFields.NullFieldsSearchRequest.Builder().setQuery(null).setIdentifier(1L).build();
  }

  @Test
  public void builderReplyWithNulls() {
    NullFields.NullFieldsSearchReply reply =
        new NullFields.NullFieldsSearchReply.Builder()
            .setResult(null)
            .setError(null)
            .setIndices(null)
            .setRequest(null)
            .setType(null)
            .build();

    assertNull(reply.getResult());
    assertNull(reply.getError());
    assertNull(reply.getIndices());
    assertNull(reply.getRequest());
    assertNull(reply.getType());
  }

  @Test
  public void requestFromMapWithValues() {
    ArrayList<Object> list = new ArrayList<Object>();
    list.add("hello");
    list.add(1L);
    ArrayList<ArrayList> wrapped = new ArrayList<ArrayList>();
    wrapped.add(list);
    NullFields.NullFieldsSearchRequest request =
        NullFields.NullFieldsSearchRequest.fromList(wrapped);
    assertEquals(request.getQuery(), "hello");
  }

  @Test
  public void requestFromMapWithNulls() {
    ArrayList<Object> list = new ArrayList<Object>();
    list.add(null);
    list.add(1L);

    ArrayList<ArrayList> wrapped = new ArrayList<ArrayList>();
    wrapped.add(list);
    NullFields.NullFieldsSearchRequest request =
        NullFields.NullFieldsSearchRequest.fromList(wrapped);
    assertNull(request.getQuery());
  }

  @Test
  public void replyFromMapWithValues() {
    ArrayList<Object> requestList = new ArrayList<Object>();

    requestList.add("hello");
    requestList.add(1L);

    ArrayList<ArrayList> wrappedRequestList = new ArrayList<ArrayList>();
    wrappedRequestList.add(requestList);

    ArrayList<Object> list = new ArrayList<Object>();

    list.add("result");
    list.add("error");
    list.add(Arrays.asList(1L, 2L, 3L));
    list.add(wrappedRequestList);
    list.add(NullFields.NullFieldsSearchReplyType.SUCCESS.ordinal());
    ArrayList<ArrayList> wrapped = new ArrayList<ArrayList>();
    wrapped.add(list);

    NullFields.NullFieldsSearchReply reply = NullFields.NullFieldsSearchReply.fromList(wrapped);
    assertEquals(reply.getResult(), "result");
    assertEquals(reply.getError(), "error");
    assertEquals(reply.getIndices(), Arrays.asList(1L, 2L, 3L));
    assertEquals(reply.getRequest().getQuery(), "hello");
    assertEquals(reply.getType(), NullFields.NullFieldsSearchReplyType.SUCCESS);
  }

  @Test
  public void replyFromMapWithNulls() {
    ArrayList<Object> list = new ArrayList<Object>();

    list.add(null);
    list.add(null);
    list.add(null);
    list.add(null);
    list.add(null);

    ArrayList<ArrayList> wrapped = new ArrayList<ArrayList>();
    wrapped.add(list);

    NullFields.NullFieldsSearchReply reply = NullFields.NullFieldsSearchReply.fromList(wrapped);
    assertNull(reply.getResult());
    assertNull(reply.getError());
    assertNull(reply.getIndices());
    assertNull(reply.getRequest());
    assertNull(reply.getType());
  }

  @Test
  public void requestToMapWithValues() {
    NullFields.NullFieldsSearchRequest request =
        new NullFields.NullFieldsSearchRequest.Builder()
            .setQuery("hello")
            .setIdentifier(1L)
            .build();

    ArrayList<ArrayList> list = request.toList();
    @SuppressWarnings("unchecked")
    ArrayList<Object> unwrapped = list.get(0);
    assertEquals(unwrapped.get(0), "hello");
  }

  @Test
  public void requestToMapWithNulls() {
    NullFields.NullFieldsSearchRequest request =
        new NullFields.NullFieldsSearchRequest.Builder().setQuery(null).setIdentifier(1L).build();

    ArrayList<ArrayList> list = request.toList();
    @SuppressWarnings("unchecked")
    ArrayList<Object> unwrapped = list.get(0);
    assertNull(unwrapped.get(0));
  }

  @Test
  public void replyToMapWithValues() {
    NullFields.NullFieldsSearchReply reply =
        new NullFields.NullFieldsSearchReply.Builder()
            .setResult("result")
            .setError("error")
            .setIndices(Arrays.asList(1L, 2L, 3L))
            .setRequest(
                new NullFields.NullFieldsSearchRequest.Builder()
                    .setQuery("hello")
                    .setIdentifier(1L)
                    .build())
            .setType(NullFields.NullFieldsSearchReplyType.SUCCESS)
            .build();

    ArrayList<ArrayList> wrapped = reply.toList();
    @SuppressWarnings("unchecked")
    ArrayList<Object> unwrapped = wrapped.get(0);
    assertEquals(unwrapped.get(0), "result");
    assertEquals(unwrapped.get(1), "error");
    assertEquals(unwrapped.get(2), Arrays.asList(1L, 2L, 3L));
    assertEquals(unwrapped.get(3), reply.getRequest().toList());
    assertEquals(unwrapped.get(4), NullFields.NullFieldsSearchReplyType.SUCCESS.ordinal());
  }

  @Test
  public void replyToMapWithNulls() {
    NullFields.NullFieldsSearchReply reply =
        new NullFields.NullFieldsSearchReply.Builder()
            .setResult(null)
            .setError(null)
            .setIndices(null)
            .setRequest(null)
            .setType(null)
            .build();

    ArrayList<ArrayList> wrapped = reply.toList();
    @SuppressWarnings("unchecked")
    ArrayList<Object> unwrapped = wrapped.get(0);

    assertNull(unwrapped.get(0));
    assertNull(unwrapped.get(1));
    assertNull(unwrapped.get(2));
    assertNull(unwrapped.get(3));
    assertNull(unwrapped.get(4));
  }
}
