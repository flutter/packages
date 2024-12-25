import 'camerax_library2.g.dart' as camerax;

export 'camerax_library2.g.dart' hide LiveData;

void setUpGenerics() {
  camerax.LiveData.pigeon_setUpMessageHandlers(
    pigeon_instanceManager: camerax.PigeonInstanceManager.instance,
    pigeon_newInstance: (camerax.LiveDataSupportedType type) {
      switch (type) {
        case camerax.LiveDataSupportedType.cameraState:
          return LiveData<camerax.CameraState>.detached(type: type);
        case camerax.LiveDataSupportedType.zoomState:
          return LiveData<camerax.ZoomState>.detached(type: type);
      }
    },
  );
}

class LiveData<T> extends camerax.LiveData {
  LiveData.detached({required super.type}) : super.pigeon_detached();

  static camerax.LiveDataSupportedType? asSupportedType(Type type) {
    switch (type) {
      case camerax.CameraState():
        return camerax.LiveDataSupportedType.cameraState;
      case camerax.ZoomState():
        return camerax.LiveDataSupportedType.zoomState;
    }

    return null;
  }

  @override
  Future<void> observe(covariant Observer<T> observer) {
    return super.observe(observer);
  }

  @override
  Future<T?> getValue() async {
    return (await super.getValue()) as T?;
  }
}

class Observer<T> extends camerax.Observer {
  Observer({
    required void Function(Observer<T> instance, T value) onChanged,
  }) : super(
          type: asSupportedType(T),
          onChanged: (
            camerax.Observer instance,
            Object value,
          ) {
            onChanged(instance as Observer<T>, value as T);
          },
        );

  static camerax.LiveDataSupportedType asSupportedType(Type type) {
    switch (type) {
      case camerax.CameraState():
        return camerax.LiveDataSupportedType.cameraState;
      case camerax.ZoomState():
        return camerax.LiveDataSupportedType.zoomState;
    }

    throw UnsupportedError('Type `$type` is unsupported.');
  }
}
