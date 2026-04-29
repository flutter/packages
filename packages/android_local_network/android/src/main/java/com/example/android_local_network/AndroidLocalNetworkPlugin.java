package com.example.android_local_network;

import android.app.Activity;
import android.content.pm.PackageManager;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

import android.os.Build;
import android.util.Log;

/**
 * AndroidLocalNetwork handles the ACCESS_LOCAL_NETWORK permission.
 * It can be used via jnigen to check and request permissions from Dart.
 */
public class AndroidLocalNetworkPlugin implements FlutterPlugin, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
    private static final String TAG = "AndroidLocalNetwork";
    private static final String PERMISSION = "android.permission.ACCESS_LOCAL_NETWORK";
    private static final int REQUEST_CODE = 4853; // Arbitrary request code

    private Activity activity;
    private PermissionCallback pendingCallback;

    /**
     * Interface for permission result callbacks.
     */
    public interface PermissionCallback {
        void onResult(boolean granted);
    }

    private static AndroidLocalNetworkPlugin instance;

    public static AndroidLocalNetworkPlugin getInstance() {
        Log.d(TAG, "getInstance called, instance is " + (instance == null ? "null" : "not null"));
        return instance;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onAttachedToEngine");
        instance = this;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onDetachedFromEngine");
        if (instance == this) {
            instance = null;
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.d(TAG, "onAttachedToActivity");
        this.activity = binding.getActivity();
        binding.addRequestPermissionsResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges");
        this.activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges");
        this.activity = binding.getActivity();
        binding.addRequestPermissionsResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity");
        this.activity = null;
    }

    /**
     * Checks if the local area permission is granted.
     */
    public boolean checkPermission() {
        if (activity == null) {
            Log.w(TAG, "checkPermission: activity is null");
            return false;
        }
        try {
            boolean granted = ContextCompat.checkSelfPermission(activity, PERMISSION) == PackageManager.PERMISSION_GRANTED;
            Log.d(TAG, "checkPermission for " + PERMISSION + ": " + granted);
            return granted;
        } catch (Exception e) {
            Log.e(TAG, "checkPermission error", e);
            return false;
        }
    }

    /**
     * Requests the local area permission.
     */
    public void requestPermission(PermissionCallback callback) {
        Log.d(TAG, "requestPermission called. Current API: " + Build.VERSION.SDK_INT);

        if (activity == null) {
            Log.w(TAG, "requestPermission: activity is null");
            callback.onResult(false);
            return;
        }

        if (checkPermission()) {
            callback.onResult(true);
            return;
        }

        pendingCallback = callback;
        Log.d(TAG, "requestPermission: requesting from OS: " + PERMISSION);
        ActivityCompat.requestPermissions(activity, new String[]{PERMISSION}, REQUEST_CODE);
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        Log.d(TAG, "onRequestPermissionsResult: requestCode=" + requestCode);
        if (requestCode == REQUEST_CODE) {
            boolean granted = grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
            Log.d(TAG, "onRequestPermissionsResult: granted=" + granted);
            if (pendingCallback != null) {
                pendingCallback.onResult(granted);
                pendingCallback = null;
            }
            return true;
        }
        return false;
    }
}
