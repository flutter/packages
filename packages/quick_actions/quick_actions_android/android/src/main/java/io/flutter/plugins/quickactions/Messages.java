// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v24.0.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon

package io.flutter.plugins.quickactions;

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

  /**
   * Home screen quick-action shortcut item.
   *
   * <p>Generated class from Pigeon that represents data sent in messages.
   */
  public static final class ShortcutItemMessage {
    /** The identifier of this item; should be unique within the app. */
    private @NonNull String type;

    public @NonNull String getType() {
      return type;
    }

    public void setType(@NonNull String setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"type\" is null.");
      }
      this.type = setterArg;
    }

    /** Localized title of the item. */
    private @NonNull String localizedTitle;

    public @NonNull String getLocalizedTitle() {
      return localizedTitle;
    }

    public void setLocalizedTitle(@NonNull String setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"localizedTitle\" is null.");
      }
      this.localizedTitle = setterArg;
    }

    /** Name of native resource to be displayed as the icon for this item. */
    private @Nullable String icon;

    public @Nullable String getIcon() {
      return icon;
    }

    public void setIcon(@Nullable String setterArg) {
      this.icon = setterArg;
    }

    /** Constructor is non-public to enforce null safety; use Builder. */
    ShortcutItemMessage() {}

    @Override
    public boolean equals(Object o) {
      if (this == o) {
        return true;
      }
      if (o == null || getClass() != o.getClass()) {
        return false;
      }
      ShortcutItemMessage that = (ShortcutItemMessage) o;
      return type.equals(that.type)
          && localizedTitle.equals(that.localizedTitle)
          && Objects.equals(icon, that.icon);
    }

    @Override
    public int hashCode() {
      return Objects.hash(type, localizedTitle, icon);
    }

    public static final class Builder {

      private @Nullable String type;

      @CanIgnoreReturnValue
      public @NonNull Builder setType(@NonNull String setterArg) {
        this.type = setterArg;
        return this;
      }

      private @Nullable String localizedTitle;

      @CanIgnoreReturnValue
      public @NonNull Builder setLocalizedTitle(@NonNull String setterArg) {
        this.localizedTitle = setterArg;
        return this;
      }

      private @Nullable String icon;

      @CanIgnoreReturnValue
      public @NonNull Builder setIcon(@Nullable String setterArg) {
        this.icon = setterArg;
        return this;
      }

      public @NonNull ShortcutItemMessage build() {
        ShortcutItemMessage pigeonReturn = new ShortcutItemMessage();
        pigeonReturn.setType(type);
        pigeonReturn.setLocalizedTitle(localizedTitle);
        pigeonReturn.setIcon(icon);
        return pigeonReturn;
      }
    }

    @NonNull
    ArrayList<Object> toList() {
      ArrayList<Object> toListResult = new ArrayList<>(3);
      toListResult.add(type);
      toListResult.add(localizedTitle);
      toListResult.add(icon);
      return toListResult;
    }

    static @NonNull ShortcutItemMessage fromList(@NonNull ArrayList<Object> pigeonVar_list) {
      ShortcutItemMessage pigeonResult = new ShortcutItemMessage();
      Object type = pigeonVar_list.get(0);
      pigeonResult.setType((String) type);
      Object localizedTitle = pigeonVar_list.get(1);
      pigeonResult.setLocalizedTitle((String) localizedTitle);
      Object icon = pigeonVar_list.get(2);
      pigeonResult.setIcon((String) icon);
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
          return ShortcutItemMessage.fromList((ArrayList<Object>) readValue(buffer));
        default:
          return super.readValueOfType(type, buffer);
      }
    }

    @Override
    protected void writeValue(@NonNull ByteArrayOutputStream stream, Object value) {
      if (value instanceof ShortcutItemMessage) {
        stream.write(129);
        writeValue(stream, ((ShortcutItemMessage) value).toList());
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
  public interface AndroidQuickActionsApi {
    /** Checks for, and returns the action that launched the app. */
    @Nullable
    String getLaunchAction();
    /** Sets the dynamic shortcuts for the app. */
    void setShortcutItems(@NonNull List<ShortcutItemMessage> itemsList, @NonNull VoidResult result);
    /** Removes all dynamic shortcuts. */
    void clearShortcutItems();

    /** The codec used by AndroidQuickActionsApi. */
    static @NonNull MessageCodec<Object> getCodec() {
      return PigeonCodec.INSTANCE;
    }
    /**
     * Sets up an instance of `AndroidQuickActionsApi` to handle messages through the
     * `binaryMessenger`.
     */
    static void setUp(
        @NonNull BinaryMessenger binaryMessenger, @Nullable AndroidQuickActionsApi api) {
      setUp(binaryMessenger, "", api);
    }

    static void setUp(
        @NonNull BinaryMessenger binaryMessenger,
        @NonNull String messageChannelSuffix,
        @Nullable AndroidQuickActionsApi api) {
      messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsApi.getLaunchAction"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                try {
                  String output = api.getLaunchAction();
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
                "dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsApi.setShortcutItems"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                List<ShortcutItemMessage> itemsListArg = (List<ShortcutItemMessage>) args.get(0);
                VoidResult resultCallback =
                    new VoidResult() {
                      public void success() {
                        wrapped.add(0, null);
                        reply.reply(wrapped);
                      }

                      public void error(Throwable error) {
                        ArrayList<Object> wrappedError = wrapError(error);
                        reply.reply(wrappedError);
                      }
                    };

                api.setShortcutItems(itemsListArg, resultCallback);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsApi.clearShortcutItems"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                try {
                  api.clearShortcutItems();
                  wrapped.add(0, null);
                } catch (Throwable exception) {
                  wrapped = wrapError(exception);
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
  /** Generated class from Pigeon that represents Flutter messages that can be called from Java. */
  public static class AndroidQuickActionsFlutterApi {
    private final @NonNull BinaryMessenger binaryMessenger;
    private final String messageChannelSuffix;

    public AndroidQuickActionsFlutterApi(@NonNull BinaryMessenger argBinaryMessenger) {
      this(argBinaryMessenger, "");
    }

    public AndroidQuickActionsFlutterApi(
        @NonNull BinaryMessenger argBinaryMessenger, @NonNull String messageChannelSuffix) {
      this.binaryMessenger = argBinaryMessenger;
      this.messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;
    }

    /** Public interface for sending reply. The codec used by AndroidQuickActionsFlutterApi. */
    static @NonNull MessageCodec<Object> getCodec() {
      return PigeonCodec.INSTANCE;
    }
    /** Sends a string representing a shortcut from the native platform to the app. */
    public void launchAction(@NonNull String actionArg, @NonNull VoidResult result) {
      final String channelName =
          "dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsFlutterApi.launchAction"
              + messageChannelSuffix;
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, channelName, getCodec());
      channel.send(
          new ArrayList<>(Collections.singletonList(actionArg)),
          channelReply -> {
            if (channelReply instanceof List) {
              List<Object> listReply = (List<Object>) channelReply;
              if (listReply.size() > 1) {
                result.error(
                    new FlutterError(
                        (String) listReply.get(0), (String) listReply.get(1), listReply.get(2)));
              } else {
                result.success();
              }
            } else {
              result.error(createConnectionError(channelName));
            }
          });
    }
  }
}
