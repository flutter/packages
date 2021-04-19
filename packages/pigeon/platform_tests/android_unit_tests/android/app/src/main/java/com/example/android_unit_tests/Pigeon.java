// Autogenerated from Pigeon (v0.2.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon

package com.example.android_unit_tests;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import java.util.HashMap;
import java.util.Map;

/** Generated class from Pigeon. */
@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression"})
public class Pigeon {

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class SetRequest {
    private Long value;

    public Long getValue() {
      return value;
    }

    public void setValue(Long setterArg) {
      this.value = setterArg;
    }

    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("value", value);
      return toMapResult;
    }

    static SetRequest fromMap(Map<String, Object> map) {
      SetRequest fromMapResult = new SetRequest();
      Object value = map.get("value");
      fromMapResult.value =
          (value == null) ? null : ((value instanceof Integer) ? (Integer) value : (Long) value);
      return fromMapResult;
    }
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter. */
  public interface Api {
    void setValue(SetRequest arg);

    /** Sets up an instance of `Api` to handle messages through the `binaryMessenger`. */
    static void setup(BinaryMessenger binaryMessenger, Api api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.Api.setValue", new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  @SuppressWarnings("ConstantConditions")
                  SetRequest input = SetRequest.fromMap((Map<String, Object>) message);
                  api.setValue(input);
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }

  private static Map<String, Object> wrapError(Throwable exception) {
    Map<String, Object> errorMap = new HashMap<>();
    errorMap.put("message", exception.toString());
    errorMap.put("code", exception.getClass().getSimpleName());
    errorMap.put("details", null);
    return errorMap;
  }
}
