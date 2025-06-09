
#ifndef CAMERA_HOST_PLUGIN_PRIVATE_H_
#define CAMERA_HOST_PLUGIN_PRIVATE_H_

#include <map>

#include "camera_texture_image_event_handler.h"
#include "flutter_linux/flutter_linux.h"
#include "messages.g.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverloaded-virtual"
#pragma clang diagnostic ignored "-Wunused-variable"

#include <pylon/PylonIncludes.h>

#include "camera.h"

#pragma clang diagnostic pop

#define CAMERA_HOST_ERROR_HANDLING(method_name, code)                          \
  try {                                                                        \
    [[maybe_unused]] auto camera_linux_camera_api_respond_macro =              \
        &camera_linux_camera_api_respond_##method_name;                        \
    [[maybe_unused]] auto camera_linux_camera_api_respond_error_macro =        \
        &camera_linux_camera_api_respond_error_##method_name;                  \
    code                                                                       \
  } catch (const Pylon::GenericException& e) {                                 \
    std::cerr << e.GetDescription() << std::endl;                              \
    camera_linux_camera_api_respond_error_##method_name(                       \
        response_handle, nullptr, e.GetDescription(), nullptr);                \
  } catch (const std::exception& e) {                                          \
    camera_linux_camera_api_respond_error_##method_name(                       \
        response_handle, nullptr, e.what(), nullptr);                          \
    std::cerr << "Exception occurred: " << e.what() << std::endl;              \
  } catch (...) {                                                              \
    camera_linux_camera_api_respond_error_##method_name(                       \
        response_handle, nullptr, "CameraLinuxPlugin Unknown error", nullptr); \
  }

#define CAMERA_HOST_RETURN(...) \
  camera_linux_camera_api_respond_macro(response_handle, __VA_ARGS__)

#define CAMERA_HOST_VOID_RETURN() \
  camera_linux_camera_api_respond_macro(response_handle)

#define CAMERA_HOST_RAISE_ERROR(description)                            \
  camera_linux_camera_api_respond_error_macro(response_handle, nullptr, \
                                              #description, nullptr)

class CameraHostPlugin {
  static FlPluginRegistrar* registrar;
  FlPluginRegistrar* m_registrar;
  static std::vector<Camera> cameras;

 public:
  CameraHostPlugin(FlPluginRegistrar* registrar);

  ~CameraHostPlugin();

  inline static Camera& get_camera_by_id(int64_t camera_id);

  static void get_available_cameras_names(
      CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data);

  static void create(const gchar* camera_name,
                     CameraLinuxPlatformResolutionPreset resolution_preset,
                     CameraLinuxCameraApiResponseHandle* response_handle,
                     gpointer user_data);

  static void initialize(int64_t camera_id,
                         CameraLinuxPlatformImageFormatGroup image_format,
                         CameraLinuxCameraApiResponseHandle* response_handle,
                         gpointer user_data);

  static void dispose(int64_t camera_id,
                      CameraLinuxCameraApiResponseHandle* response_handle,
                      gpointer user_data);

  static void get_texture_id(
      int64_t camera_id, CameraLinuxCameraApiResponseHandle* response_handle,
      gpointer user_data);

  static void take_picture(int64_t camera_id, const gchar* path,
                           CameraLinuxCameraApiResponseHandle* response_handle,
                           gpointer user_data);

  static void start_video_recording(
      int64_t camera_id, gboolean enable_stream,
      CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
    throw new std::runtime_error("Not Implemented");
  }

  static void stop_video_recording(
      int64_t camera_id, CameraLinuxCameraApiResponseHandle* response_handle,
      gpointer user_data) {
    throw new std::runtime_error("Not Implemented");
  }

  static void set_exposure_mode(
      int64_t camera_id, CameraLinuxPlatformExposureMode mode,
      CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data);

  static void set_focus_mode(
      int64_t camera_id, CameraLinuxPlatformFocusMode mode,
      CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data);

  static void camera_linux_camera_event_api_initialized_callback(
      GObject* object, GAsyncResult* result, gpointer user_data);

  static void set_image_format_group(
      int64_t camera_id, CameraLinuxPlatformImageFormatGroup image_format_group,
      CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data);
};

#endif  // CAMERA_HOST_PLUGIN_PRIVATE_H_
