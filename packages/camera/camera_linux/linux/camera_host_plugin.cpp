#include "camera_host_plugin.h"

std::map<int64_t, CameraTextureImageEventHandler*>
    CameraHostPlugin::cameraTextureImageEventHandlers = {};
std::map<int64_t, std::unique_ptr<Pylon::CInstantCamera>>
    CameraHostPlugin::cameras = {};
std::map<int64_t, CameraLinuxCameraEventApi*>
    CameraHostPlugin::cameraLinuxCameraEventApis = {};
FlPluginRegistrar* CameraHostPlugin::registrar = nullptr;

CameraHostPlugin::CameraHostPlugin(FlPluginRegistrar* registrar)
    : m_registrar(FL_PLUGIN_REGISTRAR(g_object_ref(registrar))) {
  CameraHostPlugin::registrar = m_registrar;
  static CameraLinuxCameraApiVTable api_vtable = {
      .get_available_cameras_names = get_available_cameras_names,
      .create = create,
      .initialize = initialize,
      .start_image_stream = start_image_stream,
      .stop_image_stream = stop_image_stream,
      .get_texture_id = get_texture_id,
      .received_image_stream_data = received_image_stream_data,
      .dispose = dispose,
      .lock_capture_orientation = lock_capture_orientation,
      .unlock_capture_orientation = unlock_capture_orientation,
      .take_picture = take_picture,
      .prepare_for_video_recording = prepare_for_video_recording,
      .start_video_recording = start_video_recording,
      .stop_video_recording = stop_video_recording,
      .pause_video_recording = pause_video_recording,
      .resume_video_recording = resume_video_recording,
      .set_flash_mode = set_flash_mode,
      .set_exposure_mode = set_exposure_mode,
      .set_exposure_point = set_exposure_point,
      .set_lens_position = set_lens_position,
      .get_min_exposure_offset = get_min_exposure_offset,
      .get_max_exposure_offset = get_max_exposure_offset,
      .set_exposure_offset = set_exposure_offset,
      .set_focus_mode = set_focus_mode,
      .set_focus_point = set_focus_point,
      .get_min_zoom_level = get_min_zoom_level,
      .get_max_zoom_level = get_max_zoom_level,
      .set_zoom_level = set_zoom_level,
      .pause_preview = pause_preview,
      .resume_preview = resume_preview,
      .update_description_while_recording = update_description_while_recording,
      .set_image_file_format = set_image_file_format,
  };

  camera_linux_camera_api_set_method_handlers(
      fl_plugin_registrar_get_messenger(registrar), nullptr, &api_vtable, this,
      nullptr);
  Pylon::PylonInitialize();
}

CameraHostPlugin::~CameraHostPlugin() {
  for (auto&& it = cameraLinuxCameraEventApis.begin();
       it != cameraLinuxCameraEventApis.end(); ++it) {
    g_object_unref(it->second);
  }
  cameraLinuxCameraEventApis.clear();
  for (auto&& it = cameras.begin(); it != cameras.end(); ++it) {
    it->second->Close();
  }
  cameras.clear();
  cameraTextureImageEventHandlers.clear();
  g_object_unref(m_registrar);
  Pylon::PylonTerminate();
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
    CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(create, {
    Pylon::CTlFactory& TlFactory = Pylon::CTlFactory::GetInstance();
    Pylon::DeviceInfoList_t lstDevices;
    TlFactory.EnumerateDevices(lstDevices);

    for (auto&& it = lstDevices.begin(); it != lstDevices.end(); ++it) {
      if (it->GetFriendlyName() == camera_name) {
        std::string serialNumber = it->GetSerialNumber().c_str();
        int64_t camera_id = std::stoll(serialNumber);
        if (cameras.find(camera_id) != cameras.end()) {
          cameras[camera_id]->Close();
          cameras.erase(camera_id);
        }

        cameras[camera_id] = std::make_unique<Pylon::CInstantCamera>(
            TlFactory.CreateDevice(*it));

        if (cameraLinuxCameraEventApis.find(camera_id) ==
            cameraLinuxCameraEventApis.end()) {
          cameraLinuxCameraEventApis[camera_id] =
              camera_linux_camera_event_api_new(
                  fl_plugin_registrar_get_messenger(registrar),
                  std::to_string(camera_id).c_str());
        }

        CAMERA_HOST_RETURN(camera_id);
        return;
      }
    }

    CAMERA_HOST_RAISE_ERROR("Camera not found");
  });
}

void CameraHostPlugin::camera_linux_camera_event_api_initialized_callback(
    GObject* object, GAsyncResult* result, gpointer user_data) {}

void CameraHostPlugin::initialize(
    int64_t camera_id, CameraLinuxPlatformImageFormatGroup image_format,
    CameraLinuxCameraApiResponseHandle* response_handle, gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(initialize, {
    const auto camera_it = cameras.find(camera_id);
    if (camera_it == cameras.end()) {
      CAMERA_HOST_RAISE_ERROR("Camera not created");
    }

    CameraTextureImageEventHandler* cameraTextureImageEventHandler =
        new CameraTextureImageEventHandler(registrar);
    cameraTextureImageEventHandlers[camera_id] = cameraTextureImageEventHandler;

    Pylon::CInstantCamera* camera = camera_it->second.get();
    camera->Open();
    GenApi::INodeMap& nodemap = camera->GetNodeMap();
    Pylon::CEnumParameter(nodemap, "DeviceLinkThroughputLimitMode")
        .TrySetValue("Off");
    Pylon::CBooleanParameter(nodemap, "AcquisitionFrameRateEnable")
        .TrySetValue(true);
    Pylon::CFloatParameter(nodemap, "AcquisitionFrameRate").TrySetValue(60.0);
    Pylon::CFloatParameter(nodemap, "ResultingFrameRate").TrySetValue(60.0);
    Pylon::CEnumParameter(nodemap, "PixelFormat").TrySetValue("RGB8");
    Pylon::CIntegerParameter(nodemap, "DecimationHorizontal").TrySetValue(2);
    Pylon::CIntegerParameter(nodemap, "DecimationVertical").TrySetValue(2);
    Pylon::CEnumParameter(nodemap, "TriggerMode").SetValue("Off");
    Pylon::CIntegerParameter(nodemap, "Width").TrySetValue(1920);
    Pylon::CIntegerParameter(nodemap, "Height").TrySetValue(1080);
    Pylon::CIntegerParameter(nodemap, "OffsetX").TrySetValue(0);
    Pylon::CIntegerParameter(nodemap, "OffsetY").TrySetValue(0);

    camera->RegisterImageEventHandler(cameraTextureImageEventHandler,
                                      Pylon::RegistrationMode_Append,
                                      Pylon::Cleanup_Delete);
    camera->StartGrabbing(Pylon::GrabStrategy_LatestImages,
                          Pylon::EGrabLoop::GrabLoop_ProvidedByInstantCamera);

    std::cout << "Texture ID: "
              << cameraTextureImageEventHandler->get_texture_id() << std::endl;

    CameraLinuxPlatformSize* size = camera_linux_platform_size_new(1920, 1080);
    CameraLinuxPlatformCameraState* cameraState =
        camera_linux_platform_camera_state_new(
            size,
            CameraLinuxPlatformExposureMode::
                CAMERA_LINUX_PLATFORM_EXPOSURE_MODE_LOCKED,
            CameraLinuxPlatformFocusMode::
                CAMERA_LINUX_PLATFORM_FOCUS_MODE_LOCKED,
            true, true);
    camera_linux_camera_event_api_initialized(
        cameraLinuxCameraEventApis[camera_id], cameraState, nullptr,
        camera_linux_camera_event_api_initialized_callback, nullptr);
    g_object_unref(cameraState);
    g_object_unref(size);
    CAMERA_HOST_VOID_RETURN();
  });
}

void CameraHostPlugin::get_texture_id(
    int64_t camera_id, CameraLinuxCameraApiResponseHandle* response_handle,
    gpointer user_data) {
  CAMERA_HOST_ERROR_HANDLING(get_texture_id, {
    const auto cameraTextureImageEventHandler_it =
        cameraTextureImageEventHandlers.find(camera_id);
    if (cameraTextureImageEventHandler_it ==
        cameraTextureImageEventHandlers.end()) {
      CAMERA_HOST_RAISE_ERROR("Camera not created");
    }
    CameraTextureImageEventHandler* cameraTextureImageEventHandler =
        cameraTextureImageEventHandler_it->second;
    if (cameraTextureImageEventHandler == nullptr) {
      CAMERA_HOST_RAISE_ERROR("Camera not initialized");
    }
    int64_t texture_id = cameraTextureImageEventHandler->get_texture_id();
    if (texture_id == -1) {
      CAMERA_HOST_RAISE_ERROR("Texture not created");
    }
    CAMERA_HOST_RETURN(&texture_id);
  });
}
