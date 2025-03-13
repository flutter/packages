// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon

import static java.lang.annotation.ElementType.METHOD;
import static java.lang.annotation.RetentionPolicy.CLASS;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import java.io.ByteArrayOutputStream;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/** Generated class from Pigeon. */
@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression", "serial"})
public class Messages {

  /** Error class for passing custom error details to Flutter via a thrown PlatformException. */
  public static class FlutterError extends RuntimeException {

    /** The error code. */
    public final String code;

    /** The error details. Must be a datatype supported by the api codec. */
    public final Object details;

    public FlutterError(@NonNull String code, @Nullable String message, @Nullable Object details) {
      super(message);
      this.code = code;
      this.details = details;
    }
  }

  @NonNull
  protected static ArrayList<Object> wrapError(@NonNull Throwable exception) {
    ArrayList<Object> errorList = new ArrayList<>(3);
    if (exception instanceof FlutterError) {
      FlutterError error = (FlutterError) exception;
      errorList.add(error.code);
      errorList.add(error.getMessage());
      errorList.add(error.details);
    } else {
      errorList.add(exception.toString());
      errorList.add(exception.getClass().getSimpleName());
      errorList.add(
          "Cause: " + exception.getCause() + ", Stacktrace: " + Log.getStackTraceString(exception));
    }
    return errorList;
  }

  @NonNull
  protected static FlutterError createConnectionError(@NonNull String channelName) {
    return new FlutterError(
        "channel-error", "Unable to establish connection on channel: " + channelName + ".", "");
  }

  @Target(METHOD)
  @Retention(CLASS)
  @interface CanIgnoreReturnValue {}

  public enum Code {
    ONE(0),
    TWO(1);

    final int index;

    Code(final int index) {
      this.index = index;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static final class MessageData {
    private @Nullable String name;

    public @Nullable String getName() {
      return name;
    }

    public void setName(@Nullable String setterArg) {
      this.name = setterArg;
    }

    private @Nullable String description;

    public @Nullable String getDescription() {
      return description;
    }

    public void setDescription(@Nullable String setterArg) {
      this.description = setterArg;
    }

    private @NonNull Code code;

    public @NonNull Code getCode() {
      return code;
    }

    public void setCode(@NonNull Code setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"code\" is null.");
      }
      this.code = setterArg;
    }

    private @NonNull Map<String, String> data;

    public @NonNull Map<String, String> getData() {
      return data;
    }

    public void setData(@NonNull Map<String, String> setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"data\" is null.");
      }
      this.data = setterArg;
    }

    /** Constructor is non-public to enforce null safety; use Builder. */
    MessageData() {}

    @Override
    public boolean equals(Object o) {
      if (this == o) {
        return true;
      }
      if (o == null || getClass() != o.getClass()) {
        return false;
      }
      MessageData that = (MessageData) o;
      return Objects.equals(name, that.name)
          && Objects.equals(description, that.description)
          && code.equals(that.code)
          && data.equals(that.data);
    }

    @Override
    public int hashCode() {
      return Objects.hash(name, description, code, data);
    }

    public static final class Builder {

      private @Nullable String name;

      @CanIgnoreReturnValue
      public @NonNull Builder setName(@Nullable String setterArg) {
        this.name = setterArg;
        return this;
      }

      private @Nullable String description;

      @CanIgnoreReturnValue
      public @NonNull Builder setDescription(@Nullable String setterArg) {
        this.description = setterArg;
        return this;
      }

      private @Nullable Code code;

      @CanIgnoreReturnValue
      public @NonNull Builder setCode(@NonNull Code setterArg) {
        this.code = setterArg;
        return this;
      }

      private @Nullable Map<String, String> data;

      @CanIgnoreReturnValue
      public @NonNull Builder setData(@NonNull Map<String, String> setterArg) {
        this.data = setterArg;
        return this;
      }

      public @NonNull MessageData build() {
        MessageData pigeonReturn = new MessageData();
        pigeonReturn.setName(name);
        pigeonReturn.setDescription(description);
        pigeonReturn.setCode(code);
        pigeonReturn.setData(data);
        return pigeonReturn;
      }
    }

    @NonNull
    ArrayList<Object> toList() {
      ArrayList<Object> toListResult = new ArrayList<>(4);
      toListResult.add(name);
      toListResult.add(description);
      toListResult.add(code);
      toListResult.add(data);
      return toListResult;
    }

    static @NonNull MessageData fromList(@NonNull ArrayList<Object> pigeonVar_list) {
      MessageData pigeonResult = new MessageData();
      Object name = pigeonVar_list.get(0);
      pigeonResult.setName((String) name);
      Object description = pigeonVar_list.get(1);
      pigeonResult.setDescription((String) description);
      Object code = pigeonVar_list.get(2);
      pigeonResult.setCode((Code) code);
      Object data = pigeonVar_list.get(3);
      pigeonResult.setData((Map<String, String>) data);
      return pigeonResult;
    }
  }

  private static class PigeonCodec extends StandardMessageCodec {
    public static final PigeonCodec INSTANCE = new PigeonCodec();

    private PigeonCodec() {}

    @Override
    protected Object readValueOfType(byte type, @NonNull ByteBuffer buffer) {
      switch (type) {
        case (byte) 129:
          {
            Object value = readValue(buffer);
            return value == null ? null : Code.values()[((Long) value).intValue()];
          }
        case (byte) 130:
          return MessageData.fromList((ArrayList<Object>) readValue(buffer));
        default:
          return super.readValueOfType(type, buffer);
      }
    }

    @Override
    protected void writeValue(@NonNull ByteArrayOutputStream stream, Object value) {
      if (value instanceof Code) {
        stream.write(129);
        writeValue(stream, value == null ? null : ((Code) value).index);
      } else if (value instanceof MessageData) {
        stream.write(130);
        writeValue(stream, ((MessageData) value).toList());
      } else {
        super.writeValue(stream, value);
      }
    }
  }

  /** Asynchronous error handling return type for non-nullable API method returns. */
  public interface Result<T> {
    /** Success case callback method for handling returns. */
    void success(@NonNull T result);

    /** Failure case callback method for handling errors. */
    void error(@NonNull Throwable error);
  }
  /** Asynchronous error handling return type for nullable API method returns. */
  public interface NullableResult<T> {
    /** Success case callback method for handling returns. */
    void success(@Nullable T result);

    /** Failure case callback method for handling errors. */
    void error(@NonNull Throwable error);
  }
  /** Asynchronous error handling return type for void API method returns. */
  public interface VoidResult {
    /** Success case callback method for handling returns. */
    void success();

    /** Failure case callback method for handling errors. */
    void error(@NonNull Throwable error);
  }
  /** Generated interface from Pigeon that represents a handler of messages from Flutter. */
  public interface ExampleHostApi {

    @NonNull
    String getHostLanguage();

    @NonNull
    Long add(@NonNull Long a, @NonNull Long b);

    void sendMessage(@NonNull MessageData message, @NonNull Result<Boolean> result);

    /** The codec used by ExampleHostApi. */
    static @NonNull MessageCodec<Object> getCodec() {
      return PigeonCodec.INSTANCE;
    }
    /** Sets up an instance of `ExampleHostApi` to handle messages through the `binaryMessenger`. */
    static void setUp(@NonNull BinaryMessenger binaryMessenger, @Nullable ExampleHostApi api) {
      setUp(binaryMessenger, "", api);
    }

    static void setUp(
        @NonNull BinaryMessenger binaryMessenger,
        @NonNull String messageChannelSuffix,
        @Nullable ExampleHostApi api) {
      messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.getHostLanguage"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                try {
                  String output = api.getHostLanguage();
                  wrapped.add(0, output);
                } catch (Throwable exception) {
                  wrapped = wrapError(exception);
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.add"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Long aArg = (Long) args.get(0);
                Long bArg = (Long) args.get(1);
                try {
                  Long output = api.add(aArg, bArg);
                  wrapped.add(0, output);
                } catch (Throwable exception) {
                  wrapped = wrapError(exception);
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.sendMessage"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                MessageData messageArg = (MessageData) args.get(0);
                Result<Boolean> resultCallback =
                    new Result<Boolean>() {
                      public void success(Boolean result) {
                        wrapped.add(0, result);
                        reply.reply(wrapped);
                      }

                      public void error(Throwable error) {
                        ArrayList<Object> wrappedError = wrapError(error);
                        reply.reply(wrappedError);
                      }
                    };

                api.sendMessage(messageArg, resultCallback);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
  /** Generated class from Pigeon that represents Flutter messages that can be called from Java. */
  public static class MessageFlutterApi {
    private final @NonNull BinaryMessenger binaryMessenger;
    private final String messageChannelSuffix;

    public MessageFlutterApi(@NonNull BinaryMessenger argBinaryMessenger) {
      this(argBinaryMessenger, "");
    }

    public MessageFlutterApi(
        @NonNull BinaryMessenger argBinaryMessenger, @NonNull String messageChannelSuffix) {
      this.binaryMessenger = argBinaryMessenger;
      this.messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;
    }

    /** Public interface for sending reply. The codec used by MessageFlutterApi. */
    static @NonNull MessageCodec<Object> getCodec() {
      return PigeonCodec.INSTANCE;
    }

    public void flutterMethod(@Nullable String aStringArg, @NonNull Result<String> result) {
      final String channelName =
          "dev.flutter.pigeon.pigeon_example_package.MessageFlutterApi.flutterMethod"
              + messageChannelSuffix;
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, channelName, getCodec());
      channel.send(
          new ArrayList<>(Collections.singletonList(aStringArg)),
          channelReply -> {
            if (channelReply instanceof List) {
              List<Object> listReply = (List<Object>) channelReply;
              if (listReply.size() > 1) {
                result.error(
                    new FlutterError(
                        (String) listReply.get(0), (String) listReply.get(1), listReply.get(2)));
              } else if (listReply.get(0) == null) {
                result.error(
                    new FlutterError(
                        "null-error",
                        "Flutter api returned null value for non-null return value.",
                        ""));
              } else {
                @SuppressWarnings("ConstantConditions")
                String output = (String) listReply.get(0);
                result.success(output);
              }
            } else {
              result.error(createConnectionError(channelName));
            }
          });
    }
  }
}
