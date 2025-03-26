
package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;

class FloorController {
    private final @NonNull MapsCallbackApi flutterApi;

    FloorController(@NonNull Messages.MapsCallbackApi flutterApi) {
        this.flutterApi = flutterApi;
    }

    void onActiveLevelChanged(String floorShortName) {
        flutterApi.onActiveLevelChanged(floorShortName, new NoOpVoidResult());
    }
}
