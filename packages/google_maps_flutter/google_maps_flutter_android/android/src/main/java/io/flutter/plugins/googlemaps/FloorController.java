
package io.flutter.plugins.googlemaps;

import static io.flutter.plugins.googlemaps.Convert.indoorLevelToPigeon;

import androidx.annotation.NonNull;

import com.google.android.gms.maps.model.IndoorLevel;

import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;

class FloorController {
    private final @NonNull MapsCallbackApi flutterApi;

    FloorController(@NonNull Messages.MapsCallbackApi flutterApi) {
        this.flutterApi = flutterApi;
    }

    void onActiveLevelChanged(IndoorLevel indoorLevel) {
        flutterApi.onActiveLevelChanged(indoorLevel == null ? null : Convert.indoorLevelToPigeon(indoorLevel), new NoOpVoidResult());
    }
}
