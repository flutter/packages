// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.android_unit_tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
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
            .setType(NullFields.NullFieldsSearchReplyType.success)
            .build();

    assertEquals(reply.getResult(), "result");
    assertEquals(reply.getError(), "error");
    assertEquals(reply.getIndices(), Arrays.asList(1L, 2L, 3L));
    assertEquals(reply.getRequest().getQuery(), "hello");
    assertEquals(reply.getType(), NullFields.NullFieldsSearchReplyType.success);
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
    HashMap<String, Object> map = new HashMap<>();
    map.put("query", "hello");
    map.put("identifier", 1L);

    NullFields.NullFieldsSearchRequest request = NullFields.NullFieldsSearchRequest.fromMap(map);
    assertEquals(request.getQuery(), "hello");
  }

  @Test
  public void requestFromMapWithNulls() {
    HashMap<String, Object> map = new HashMap<>();
    map.put("query", null);
    map.put("identifier", 1L);

    NullFields.NullFieldsSearchRequest request = NullFields.NullFieldsSearchRequest.fromMap(map);
    assertNull(request.getQuery());
  }

  @Test
  public void replyFromMapWithValues() {
    HashMap<String, Object> requestMap = new HashMap<>();
    requestMap.put("query", "hello");
    requestMap.put("identifier", 1L);

    HashMap<String, Object> map = new HashMap<>();
    map.put("result", "result");
    map.put("error", "error");
    map.put("indices", Arrays.asList(1L, 2L, 3L));
    map.put("request", requestMap);
    map.put("type", NullFields.NullFieldsSearchReplyType.success.ordinal());

    NullFields.NullFieldsSearchReply reply = NullFields.NullFieldsSearchReply.fromMap(map);
    assertEquals(reply.getResult(), "result");
    assertEquals(reply.getError(), "error");
    assertEquals(reply.getIndices(), Arrays.asList(1L, 2L, 3L));
    assertEquals(reply.getRequest().getQuery(), "hello");
    assertEquals(reply.getType(), NullFields.NullFieldsSearchReplyType.success);
  }

  @Test
  public void replyFromMapWithNulls() {
    HashMap<String, Object> map = new HashMap<>();
    map.put("result", null);
    map.put("error", null);
    map.put("indices", null);
    map.put("request", null);
    map.put("type", null);

    NullFields.NullFieldsSearchReply reply = NullFields.NullFieldsSearchReply.fromMap(map);
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

    Map<String, Object> map = request.toMap();
    assertEquals(map.get("query"), "hello");
  }

  @Test
  public void requestToMapWithNulls() {
    NullFields.NullFieldsSearchRequest request =
        new NullFields.NullFieldsSearchRequest.Builder().setQuery(null).setIdentifier(1L).build();

    Map<String, Object> map = request.toMap();
    assertNull(map.get("query"));
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
            .setType(NullFields.NullFieldsSearchReplyType.success)
            .build();

    Map<String, Object> map = reply.toMap();
    assertEquals(map.get("result"), "result");
    assertEquals(map.get("error"), "error");
    assertEquals(map.get("indices"), Arrays.asList(1L, 2L, 3L));
    assertEquals(map.get("request"), reply.getRequest().toMap());
    assertEquals(map.get("type"), NullFields.NullFieldsSearchReplyType.success.ordinal());
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

    Map<String, Object> map = reply.toMap();
    assertNull(map.get("result"));
    assertNull(map.get("error"));
    assertNull(map.get("indices"));
    assertNull(map.get("request"));
    assertNull(map.get("type"));
  }
}
