// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.6.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

package io.flutter.plugins.videoplayer;

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

  @Target(METHOD)
  @Retention(CLASS)
  @interface CanIgnoreReturnValue {}

  /** Pigeon equivalent of VideoViewType. */
  public enum PlatformVideoViewType {
    TEXTURE_VIEW(0),
    PLATFORM_VIEW(1);

    final int index;

    PlatformVideoViewType(final int index) {
      this.index = index;
    }
  }

  /**
   * Information passed to the platform view creation.
   *
   * <p>Generated class from Pigeon that represents data sent in messages.
   */
  public static final class PlatformVideoViewCreationParams {
    private @NonNull Long playerId;

    public @NonNull Long getPlayerId() {
      return playerId;
    }

    public void setPlayerId(@NonNull Long setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"playerId\" is null.");
      }
      this.playerId = setterArg;
    }

    /** Constructor is non-public to enforce null safety; use Builder. */
    PlatformVideoViewCreationParams() {}

    @Override
    public boolean equals(Object o) {
      if (this == o) {
        return true;
      }
      if (o == null || getClass() != o.getClass()) {
        return false;
      }
      PlatformVideoViewCreationParams that = (PlatformVideoViewCreationParams) o;
      return playerId.equals(that.playerId);
    }

    @Override
    public int hashCode() {
      return Objects.hash(playerId);
    }

    public static final class Builder {

      private @Nullable Long playerId;

      @CanIgnoreReturnValue
      public @NonNull Builder setPlayerId(@NonNull Long setterArg) {
        this.playerId = setterArg;
        return this;
      }

      public @NonNull PlatformVideoViewCreationParams build() {
        PlatformVideoViewCreationParams pigeonReturn = new PlatformVideoViewCreationParams();
        pigeonReturn.setPlayerId(playerId);
        return pigeonReturn;
      }
    }

    @NonNull
    ArrayList<Object> toList() {
      ArrayList<Object> toListResult = new ArrayList<>(1);
      toListResult.add(playerId);
      return toListResult;
    }

    static @NonNull PlatformVideoViewCreationParams fromList(
        @NonNull ArrayList<Object> pigeonVar_list) {
      PlatformVideoViewCreationParams pigeonResult = new PlatformVideoViewCreationParams();
      Object playerId = pigeonVar_list.get(0);
      pigeonResult.setPlayerId((Long) playerId);
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static final class CreateMessage {
    private @Nullable String asset;

    public @Nullable String getAsset() {
      return asset;
    }

    public void setAsset(@Nullable String setterArg) {
      this.asset = setterArg;
    }

    private @Nullable String uri;

    public @Nullable String getUri() {
      return uri;
    }

    public void setUri(@Nullable String setterArg) {
      this.uri = setterArg;
    }

    private @Nullable String packageName;

    public @Nullable String getPackageName() {
      return packageName;
    }

    public void setPackageName(@Nullable String setterArg) {
      this.packageName = setterArg;
    }

    private @Nullable String formatHint;

    public @Nullable String getFormatHint() {
      return formatHint;
    }

    public void setFormatHint(@Nullable String setterArg) {
      this.formatHint = setterArg;
    }

    private @NonNull Map<String, String> httpHeaders;

    public @NonNull Map<String, String> getHttpHeaders() {
      return httpHeaders;
    }

    public void setHttpHeaders(@NonNull Map<String, String> setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"httpHeaders\" is null.");
      }
      this.httpHeaders = setterArg;
    }

    private @Nullable PlatformVideoViewType viewType;

    public @Nullable PlatformVideoViewType getViewType() {
      return viewType;
    }

    public void setViewType(@Nullable PlatformVideoViewType setterArg) {
      this.viewType = setterArg;
    }

    /** Constructor is non-public to enforce null safety; use Builder. */
    CreateMessage() {}

    @Override
    public boolean equals(Object o) {
      if (this == o) {
        return true;
      }
      if (o == null || getClass() != o.getClass()) {
        return false;
      }
      CreateMessage that = (CreateMessage) o;
      return Objects.equals(asset, that.asset)
          && Objects.equals(uri, that.uri)
          && Objects.equals(packageName, that.packageName)
          && Objects.equals(formatHint, that.formatHint)
          && httpHeaders.equals(that.httpHeaders)
          && Objects.equals(viewType, that.viewType);
    }

    @Override
    public int hashCode() {
      return Objects.hash(asset, uri, packageName, formatHint, httpHeaders, viewType);
    }

    public static final class Builder {

      private @Nullable String asset;

      @CanIgnoreReturnValue
      public @NonNull Builder setAsset(@Nullable String setterArg) {
        this.asset = setterArg;
        return this;
      }

      private @Nullable String uri;

      @CanIgnoreReturnValue
      public @NonNull Builder setUri(@Nullable String setterArg) {
        this.uri = setterArg;
        return this;
      }

      private @Nullable String packageName;

      @CanIgnoreReturnValue
      public @NonNull Builder setPackageName(@Nullable String setterArg) {
        this.packageName = setterArg;
        return this;
      }

      private @Nullable String formatHint;

      @CanIgnoreReturnValue
      public @NonNull Builder setFormatHint(@Nullable String setterArg) {
        this.formatHint = setterArg;
        return this;
      }

      private @Nullable Map<String, String> httpHeaders;

      @CanIgnoreReturnValue
      public @NonNull Builder setHttpHeaders(@NonNull Map<String, String> setterArg) {
        this.httpHeaders = setterArg;
        return this;
      }

      private @Nullable PlatformVideoViewType viewType;

      @CanIgnoreReturnValue
      public @NonNull Builder setViewType(@Nullable PlatformVideoViewType setterArg) {
        this.viewType = setterArg;
        return this;
      }

      public @NonNull CreateMessage build() {
        CreateMessage pigeonReturn = new CreateMessage();
        pigeonReturn.setAsset(asset);
        pigeonReturn.setUri(uri);
        pigeonReturn.setPackageName(packageName);
        pigeonReturn.setFormatHint(formatHint);
        pigeonReturn.setHttpHeaders(httpHeaders);
        pigeonReturn.setViewType(viewType);
        return pigeonReturn;
      }
    }

    @NonNull
    ArrayList<Object> toList() {
      ArrayList<Object> toListResult = new ArrayList<>(6);
      toListResult.add(asset);
      toListResult.add(uri);
      toListResult.add(packageName);
      toListResult.add(formatHint);
      toListResult.add(httpHeaders);
      toListResult.add(viewType);
      return toListResult;
    }

    static @NonNull CreateMessage fromList(@NonNull ArrayList<Object> pigeonVar_list) {
      CreateMessage pigeonResult = new CreateMessage();
      Object asset = pigeonVar_list.get(0);
      pigeonResult.setAsset((String) asset);
      Object uri = pigeonVar_list.get(1);
      pigeonResult.setUri((String) uri);
      Object packageName = pigeonVar_list.get(2);
      pigeonResult.setPackageName((String) packageName);
      Object formatHint = pigeonVar_list.get(3);
      pigeonResult.setFormatHint((String) formatHint);
      Object httpHeaders = pigeonVar_list.get(4);
      pigeonResult.setHttpHeaders((Map<String, String>) httpHeaders);
      Object viewType = pigeonVar_list.get(5);
      pigeonResult.setViewType((PlatformVideoViewType) viewType);
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
            return value == null ? null : PlatformVideoViewType.values()[((Long) value).intValue()];
          }
        case (byte) 130:
          return PlatformVideoViewCreationParams.fromList((ArrayList<Object>) readValue(buffer));
        case (byte) 131:
          return CreateMessage.fromList((ArrayList<Object>) readValue(buffer));
        default:
          return super.readValueOfType(type, buffer);
      }
    }

    @Override
    protected void writeValue(@NonNull ByteArrayOutputStream stream, Object value) {
      if (value instanceof PlatformVideoViewType) {
        stream.write(129);
        writeValue(stream, value == null ? null : ((PlatformVideoViewType) value).index);
      } else if (value instanceof PlatformVideoViewCreationParams) {
        stream.write(130);
        writeValue(stream, ((PlatformVideoViewCreationParams) value).toList());
      } else if (value instanceof CreateMessage) {
        stream.write(131);
        writeValue(stream, ((CreateMessage) value).toList());
      } else {
        super.writeValue(stream, value);
      }
    }
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter. */
  public interface AndroidVideoPlayerApi {

    void initialize();

    @NonNull
    Long create(@NonNull CreateMessage msg);

    void dispose(@NonNull Long playerId);

    void setLooping(@NonNull Long playerId, @NonNull Boolean looping);

    void setVolume(@NonNull Long playerId, @NonNull Double volume);

    void setPlaybackSpeed(@NonNull Long playerId, @NonNull Double speed);

    void play(@NonNull Long playerId);

    @NonNull
    Long position(@NonNull Long playerId);

    void seekTo(@NonNull Long playerId, @NonNull Long position);

    void pause(@NonNull Long playerId);

    void setMixWithOthers(@NonNull Boolean mixWithOthers);

    /** The codec used by AndroidVideoPlayerApi. */
    static @NonNull MessageCodec<Object> getCodec() {
      return PigeonCodec.INSTANCE;
    }

    /**
     * Sets up an instance of `AndroidVideoPlayerApi` to handle messages through the
     * `binaryMessenger`.
     */
    static void setUp(
        @NonNull BinaryMessenger binaryMessenger, @Nullable AndroidVideoPlayerApi api) {
      setUp(binaryMessenger, "", api);
    }

    static void setUp(
        @NonNull BinaryMessenger binaryMessenger,
        @NonNull String messageChannelSuffix,
        @Nullable AndroidVideoPlayerApi api) {
      messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.initialize"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                try {
                  api.initialize();
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
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.create"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                CreateMessage msgArg = (CreateMessage) args.get(0);
                try {
                  Long output = api.create(msgArg);
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
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.dispose"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Long playerIdArg = (Long) args.get(0);
                try {
                  api.dispose(playerIdArg);
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
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.setLooping"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Long playerIdArg = (Long) args.get(0);
                Boolean loopingArg = (Boolean) args.get(1);
                try {
                  api.setLooping(playerIdArg, loopingArg);
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
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.setVolume"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Long playerIdArg = (Long) args.get(0);
                Double volumeArg = (Double) args.get(1);
                try {
                  api.setVolume(playerIdArg, volumeArg);
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
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.setPlaybackSpeed"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Long playerIdArg = (Long) args.get(0);
                Double speedArg = (Double) args.get(1);
                try {
                  api.setPlaybackSpeed(playerIdArg, speedArg);
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
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.play"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Long playerIdArg = (Long) args.get(0);
                try {
                  api.play(playerIdArg);
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
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.position"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Long playerIdArg = (Long) args.get(0);
                try {
                  Long output = api.position(playerIdArg);
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
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.seekTo"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Long playerIdArg = (Long) args.get(0);
                Long positionArg = (Long) args.get(1);
                try {
                  api.seekTo(playerIdArg, positionArg);
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
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.pause"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Long playerIdArg = (Long) args.get(0);
                try {
                  api.pause(playerIdArg);
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
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.video_player_android.AndroidVideoPlayerApi.setMixWithOthers"
                    + messageChannelSuffix,
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                ArrayList<Object> wrapped = new ArrayList<>();
                ArrayList<Object> args = (ArrayList<Object>) message;
                Boolean mixWithOthersArg = (Boolean) args.get(0);
                try {
                  api.setMixWithOthers(mixWithOthersArg);
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
}
