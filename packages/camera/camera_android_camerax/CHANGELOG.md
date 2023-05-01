## NEXT

* Updates minimum Flutter version to 3.3.
* Creates camera_android_camerax plugin for development.
* Adds CameraInfo class and removes unnecessary code from plugin.
* Adds CameraSelector class.
* Adds ProcessCameraProvider class.
* Bump CameraX version to 1.3.0-alpha02.
* Adds Camera and UseCase classes, along with methods for binding UseCases to a lifecycle with the ProcessCameraProvider.
* Bump CameraX version to 1.3.0-alpha03 and Kotlin version to 1.8.0.
* Changes instance manager to allow the separate creation of identical objects.
* Adds Preview and Surface classes, along with other methods needed to implement camera preview.
* Adds implementation of availableCameras().
* Implements camera preview, createCamera, initializeCamera, onCameraError, onDeviceOrientationChanged, and onCameraInitialized.
* Adds integration test to plugin.
* Bump CameraX version to 1.3.0-alpha04.
* Fixes instance manager hot restart behavior and fixes Java casting issue.
* Implements image capture.
* Fixes cast of CameraInfo to fix integration test failure.
* Updates internal Java InstanceManager to only stop finalization callbacks when stopped.
* Implements image streaming.
* Provides LifecycleOwner implementation for Activities that use the plugin that do not implement it themselves.
* Implements retrieval of camera information.
