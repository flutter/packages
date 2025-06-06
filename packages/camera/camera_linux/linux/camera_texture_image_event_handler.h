
#ifndef CAMERA_TEXTURE_IMAGE_EVENT_HANDLER_H_
#define CAMERA_TEXTURE_IMAGE_EVENT_HANDLER_H_

#include <GL/gl.h>

#include "camera.h"
#include "flutter_linux/flutter_linux.h"
#include "messages.g.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverloaded-virtual"
#pragma clang diagnostic ignored "-Wunused-variable"

#include <pylon/PylonIncludes.h>

#pragma clang diagnostic pop

G_DECLARE_FINAL_TYPE(FlMyTextureGL, fl_my_texture_gl, FL, MY_TEXTURE_GL,
                     FlTextureGL)

struct _FlMyTextureGL {
  FlTextureGL parent_instance;
  uint32_t target;
  uint32_t name;
  uint32_t width;
  uint32_t height;
};

FlMyTextureGL* fl_my_texture_gl_new(uint32_t target, uint32_t name,
                                    uint32_t width, uint32_t height);

class CameraTextureImageEventHandler : public Pylon::CImageEventHandler {
  FlMyTextureGL* m_texture;
  unsigned int m_texture_name;
  const Camera& camera;
  FlPluginRegistrar* m_registrar;
  FlTextureRegistrar* m_texture_registrar;
  GdkGLContext* m_gl_context;

  GLuint m_input_texture = 0;
  GLuint m_output_texture = 0;
  GLuint m_fbo = 0;
  GLuint m_shader_program = 0;
  GLuint m_vao = 0, m_vbo = 0;

 public:
  CameraTextureImageEventHandler(const Camera& camera,
                                 FlPluginRegistrar* registrar);

  ~CameraTextureImageEventHandler() override;

  int64_t get_texture_id();

  void OnImageEventHandlerRegistered(Pylon::CInstantCamera& camera) override;

  void OnImageGrabbed(Pylon::CInstantCamera& camera,
                      const Pylon::CGrabResultPtr& ptr) override;

  void OnImageEventHandlerDeregistered(Pylon::CInstantCamera& camera) override;
};

#endif  // CAMERA_TEXTURE_IMAGE_EVENT_HANDLER_H_
