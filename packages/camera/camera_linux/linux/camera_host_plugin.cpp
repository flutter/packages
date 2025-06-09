#include "camera_host_plugin.h"

std::vector<Camera> CameraHostPlugin::cameras = {};
FlPluginRegistrar* CameraHostPlugin::registrar = nullptr;

CameraHostPlugin::CameraHostPlugin(FlPluginRegistrar* registrar)
    : m_registrar(FL_PLUGIN_REGISTRAR(g_object_ref(registrar))) {
  CameraHostPlugin::registrar = m_registrar;
  static CameraLinuxCameraApiVTable api_vtable = {
      .get_available_cameras_names = get_available_cameras_names,
      .create = create,
      .initialize = initialize,
      .get_texture_id = get_texture_id,
      .dispose = dispose,
      .take_picture = take_picture,
      .start_video_recording = start_video_recording,
      .stop_video_recording = stop_video_recording,
      .set_exposure_mode = set_exposure_mode,
      .set_focus_mode = set_focus_mode,
      .set_image_format_group = set_image_format_group,
  };

  camera_linux_camera_api_set_method_handlers(
      fl_plugin_registrar_get_messenger(registrar), nullptr, &api_vtable, this,
      nullptr);
  Pylon::PylonInitialize();
}

CameraHostPlugin::~CameraHostPlugin() {
  cameras.clear();
  g_object_unref(m_registrar);
  Pylon::PylonTerminate();
}

inline Camera& CameraHostPlugin::get_camera_by_id(int64_t camera_id) {
  for (size_t i = 0; i < cameras.size(); ++i) {
    if (cameras[i].camera_id == camera_id) {
      return cameras[i];
    }
  }
  throw std::runtime_error("Camera not found");
}

void CameraHostPlugin::get_available_cameras_names(
    CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(get_available_cameras_names, {
    Pylon::CTlFactory& TlFactory = Pylon::CTlFactory::GetInstance();
    Pylon::DeviceInfoList_t lstDevices;
    TlFactory.EnumerateDevices(lstDevices);
    FlValue* list = fl_value_new_list();

    if (!lstDevices.empty()) {
      for (auto&& it = lstDevices.begin(); it != lstDevices.end(); ++it) {
        fl_value_append_take(list, fl_value_new_string(it->GetFriendlyName()));
      }
    }

    CAMERA_HOST_RETURN(list);
  });
}

void CameraHostPlugin::create(
    const gchar* camera_name,
    CameraLinuxPlatformResolutionPreset resolution_preset,
    CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(create, {
    Pylon::CTlFactory& TlFactory = Pylon::CTlFactory::GetInstance();
    Pylon::DeviceInfoList_t lstDevices;
    TlFactory.EnumerateDevices(lstDevices);

    for (auto&& it = lstDevices.begin(); it != lstDevices.end(); ++it) {
      if (it->GetFriendlyName() == camera_name) {
        std::string serialNumber = it->GetSerialNumber().c_str();
        int64_t camera_id = std::stoll(serialNumber);
        for (auto&& camera_it = cameras.begin(); camera_it != cameras.end();
             ++camera_it) {
          if (camera_it->camera_id == camera_id) {
            cameras.erase(camera_it);
            break;
          }
        }
        cameras.emplace_back(TlFactory.CreateDevice(*it), camera_id, registrar,
                             resolution_preset);

        CAMERA_HOST_RETURN(camera_id);
        return;
      }
    }

    CAMERA_HOST_RAISE_ERROR("Camera not found");
  });
}

void CameraHostPlugin::dispose(
    int64_t camera_id, CameraLinuxCameraApiResponseHandle* response_handle,
    gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(dispose, {
    for (auto&& camera_it = cameras.begin(); camera_it != cameras.end();
         ++camera_it) {
      if (camera_it->camera_id == camera_id) {
        cameras.erase(camera_it);
      }
    }
    CAMERA_HOST_VOID_RETURN();
  });
}

void CameraHostPlugin::camera_linux_camera_event_api_initialized_callback(
    GObject* object, GAsyncResult* result, gpointer user_data) {}

void CameraHostPlugin::set_image_format_group(
    int64_t camera_id, CameraLinuxPlatformImageFormatGroup image_format_group,
    CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(set_image_format_group, {
    Camera& camera = get_camera_by_id(camera_id);
    camera.setImageFormatGroup(image_format_group);
    CAMERA_HOST_VOID_RETURN();
  });
}

void CameraHostPlugin::initialize(
    int64_t camera_id, CameraLinuxPlatformImageFormatGroup image_format,
    CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(initialize, {
    Camera& camera = get_camera_by_id(camera_id);
    camera.initialize(image_format);
    CAMERA_HOST_VOID_RETURN();
  });
}

void CameraHostPlugin::get_texture_id(
    int64_t camera_id, CameraLinuxCameraApiResponseHandle* response_handle,
    gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(get_texture_id, {
    Camera& camera = get_camera_by_id(camera_id);
    int64_t texture_id = camera.getTextureId();
    if (texture_id == -1) {
      CAMERA_HOST_RAISE_ERROR("Texture not created");
    }
    CAMERA_HOST_RETURN(&texture_id);
  });
}

void CameraHostPlugin::set_exposure_mode(
    int64_t camera_id, CameraLinuxPlatformExposureMode mode,
    CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(set_exposure_mode, {
    Camera& camera = get_camera_by_id(camera_id);
    camera.setExposureMode(mode);

    CAMERA_HOST_VOID_RETURN();
  });
}

void CameraHostPlugin::set_focus_mode(
    int64_t camera_id, CameraLinuxPlatformFocusMode mode,
    CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(set_focus_mode, {
    Camera& camera = get_camera_by_id(camera_id);
    camera.setFocusMode(mode);

    CAMERA_HOST_VOID_RETURN();
  });
}

void CameraHostPlugin::take_picture(
    int64_t camera_id, const gchar* path,
    CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(take_picture, {
    Camera& camera = get_camera_by_id(camera_id);

    camera.takePicture(std::string(path));
    CAMERA_HOST_VOID_RETURN();
  });
}