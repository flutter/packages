#include "include/camera_linux/camera_plugin.h"

#include "camera_host_plugin.h"

void camera_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  CameraHostPlugin* camera_host_plugin = new CameraHostPlugin(registrar);
  g_object_unref(camera_host_plugin);
}
