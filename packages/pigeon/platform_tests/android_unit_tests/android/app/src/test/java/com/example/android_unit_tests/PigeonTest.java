package com.example.android_unit_tests;

import static org.junit.Assert.*;

import java.util.Map;
import org.junit.Test;

public class PigeonTest {
  @Test
  public void toMapAndBack() {
    Pigeon.SetRequest request = new Pigeon.SetRequest();
    request.setValue(1234l);
    Map<String, Object> map = request.toMap();
    Pigeon.SetRequest readRequest = Pigeon.SetRequest.fromMap(map);
    assertEquals(request.getValue(), readRequest.getValue());
  }
}
