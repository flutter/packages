
#ifndef CAPTURE_PIPELINE_H_
#define CAPTURE_PIPELINE_H_

#include <GL/gl.h>

#include <functional>

#include "fl_lightx_texture_gl.h"
#include "flutter_linux/flutter_linux.h"
#include "messages.g.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverloaded-virtual"
#pragma clang diagnostic ignored "-Wunused-variable"

#include <pylon/PylonIncludes.h>

#pragma clang diagnostic pop

#include <mutex>
#include <vector>

#define RING_BUFFER_SIZE 2

class Camera;

class CapturePipeline {
 public:
  CapturePipeline(const Camera& camera, FlPluginRegistrar* registrar);
  ~CapturePipeline();

  void StartGrabbing();
  void StopGrabbing();

  int64_t get_texture_id();

 private:
  const Camera& camera;

  // FL Texture
  FlLightxTextureGL* m_fl_texture;
  unsigned int m_fl_texture_name;
  FlPluginRegistrar* m_fl_registrar;
  FlTextureRegistrar* m_fl_texture_registrar;
  GdkGLContext* m_gl_context;

  // OpenGL resources
  GLuint m_pbo_ring_buffer[RING_BUFFER_SIZE];
  GLuint m_exposure_textures[RING_BUFFER_SIZE] = {0};
  size_t m_ring_buffer_index;

  // motion mask texture
  // GLuint m_motion_mask_texture;

  // hdr fusion GPU shader pass
  GLuint m_hdr_fusion_shader_program;
  GLuint m_hdr_fusion_vao, m_hdr_fusion_vbo;
  GLuint m_hdr_fusion_fbo;

  // tone mapping GPU shader pass
  // GLuint m_tone_mapping_shader_program;
  // GLuint m_tone_mapping_vao, m_tone_mapping_vbo;
  // GLuint m_tone_mapping_fbo;

  // mono texture GPU shader pass
  // GLuint m_mono_shader_program;
  // GLuint m_mono_fbo;

  // output texture
  GLuint m_output_texture;

  void OnImageGrabbed(const Pylon::CGrabResultPtr& grabResult);
  void GLInit();
  void OnNewFrame();
  GLuint compileShader(GLenum type, const char* src);
  GLuint createMonoShaderProgram();
  GLuint createHDRShaderProgram();
  void notifyTextureReady();
};

#endif  // CAPTURE_PIPELINE_H_
