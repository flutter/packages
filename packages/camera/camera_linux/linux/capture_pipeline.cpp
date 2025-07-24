
#include "capture_pipeline.h"

#include <GLES3/gl3.h>

#include <thread>

#include "camera.h"

CapturePipeline::CapturePipeline(const Camera& camera,
                                 FlPluginRegistrar* registrar)
    : camera{camera},
      m_fl_registrar(registrar),
      m_fl_texture_registrar(
          fl_plugin_registrar_get_texture_registrar(registrar)) {}

CapturePipeline::~CapturePipeline() {
  if (m_fl_texture) {
    glDeleteTextures(1, &m_fl_texture_name);
    fl_texture_registrar_unregister_texture(m_fl_texture_registrar,
                                            FL_TEXTURE(m_fl_texture));
    g_object_unref(m_fl_texture);
  }
}

//   GenApi::INodeMap& nodemap = camera->GetNodeMap();
//   Pylon::CEnumParameter(nodemap, "TriggerSelector").SetValue("FrameStart");
//   Pylon::CEnumParameter(nodemap, "TriggerMode").SetValue("On");
//   Pylon::CEnumParameter(nodemap, "TriggerSource").SetValue("Software");

//   // Manual grab loop with exposure bracketing
//   cameraTextureImageEventHandler->OnImageEventHandlerRegistered(*camera);

//   camera->StartGrabbing(Pylon::GrabStrategy_OneByOne,
//                         Pylon::EGrabLoop::GrabLoop_ProvidedByUser);

//   std::thread([this]() {
//     double shortExposure = 1000.0;  // µs - initial value
//     // double longExposure = 128000.0;  // µs
//     // const double gain = 0.6;
//     // const double targetBrightness = 120.0;  // target average
//     // brightness

//     // const double overblownTargetRatio = 0.01;  // 3%
//     // const double overblownThreshold = 240.0;

//     auto& nodemap = camera->GetNodeMap();
//     // const double minExposure =
//     //     Pylon::CFloatParameter(nodemap, "ExposureTime").GetMin();
//     // const double maxExposure =
//     //     Pylon::CFloatParameter(nodemap, "ExposureTime").GetMax();

//     while (camera->IsGrabbing()) {
//       // --- Short exposure ---
//       Pylon::CFloatParameter(nodemap, "ExposureTime")
//           .TrySetValue(shortExposure);
//       camera->WaitForFrameTriggerReady(5000,
//                                        Pylon::TimeoutHandling_ThrowException);
//       camera->ExecuteSoftwareTrigger();

//       Pylon::CGrabResultPtr shortResult;
//       camera->RetrieveResult(5000, shortResult,
//                              Pylon::TimeoutHandling_ThrowException);

//       // if (shortResult && shortResult->GrabSucceeded()) {
//       //   cameraTextureImageEventHandler->OnImageGrabbed(*camera,
//       //   shortResult);

//       //   // === Adjust short exposure for overblown % ===
//       //   const int width = shortResult->GetWidth();
//       //   const int height = shortResult->GetHeight();
//       //   const uint8_t* buffer =
//       //       static_cast<const uint8_t*>(shortResult->GetBuffer());

//       //   const int cx = width / 2;
//       //   const int cy = height / 2;
//       //   const int radius = std::min(width, height) / 4;

//       //   size_t overblown = 0;
//       //   size_t total = 0;

//       //   for (int y = 0; y < height; ++y) {
//       //     for (int x = 0; x < width; ++x) {
//       //       int dx = x - cx;
//       //       int dy = y - cy;
//       //       if (dx * dx + dy * dy <= radius * radius) {
//       //         int index = (y * width + x) * 3;
//       //         uint8_t r = buffer[index];
//       //         uint8_t g = buffer[index + 1];
//       //         uint8_t b = buffer[index + 2];
//       //         double luminance = 0.299 * r + 0.587 * g + 0.114 * b;

//       //         if (luminance >= overblownThreshold) {
//       //           overblown++;
//       //         }
//       //         total++;
//       //       }
//       //     }
//       //   }

//       //   if (total > 0) {
//       //     double ratio = static_cast<double>(overblown) / total;
//       //     double error = overblownTargetRatio - ratio;

//       //     // Adjust short exposure proportionally
//       //     double proposed =
//       //         shortExposure * (1.0 + gain * error /
//       //         overblownTargetRatio);
//       //     shortExposure =
//       //         std::max(minExposure, std::min(maxExposure, proposed));
//       //   }
//       // }

//       // // --- Long exposure ---
//       // Pylon::CFloatParameter(nodemap,
//       // "ExposureTime").TrySetValue(longExposure);
//       // camera->WaitForFrameTriggerReady(5000,
//       // Pylon::TimeoutHandling_ThrowException);
//       // camera->ExecuteSoftwareTrigger();

//       // Pylon::CGrabResultPtr longResult;
//       // camera->RetrieveResult(5000, longResult,
//       //                        Pylon::TimeoutHandling_ThrowException);
//       // if (longResult && longResult->GrabSucceeded()) {
//       //   cameraTextureImageEventHandler->OnImageGrabbed(*camera,
//       //   longResult);

//       //   // === Adjust long exposure brightness as before ===
//       //   const int width = longResult->GetWidth();
//       //   const int height = longResult->GetHeight();
//       //   const uint8_t* buffer =
//       //       static_cast<const uint8_t*>(longResult->GetBuffer());

//       //   const int cx = width / 2;
//       //   const int cy = height / 2;
//       //   const int radius = std::min(width, height) / 4;

//       //   uint64_t sum = 0;
//       //   size_t count = 0;

//       //   for (int y = 0; y < height; ++y) {
//       //     for (int x = 0; x < width; ++x) {
//       //       int dx = x - cx;
//       //       int dy = y - cy;
//       //       if (dx * dx + dy * dy <= radius * radius) {
//       //         int index = (y * width + x) * 3;
//       //         uint8_t r = buffer[index];
//       //         uint8_t g = buffer[index + 1];
//       //         uint8_t b = buffer[index + 2];
//       //         double luminance = 0.299 * r + 0.587 * g + 0.114 * b;

//       //         if (luminance > 10 && luminance < 240) {
//       //           sum += luminance;
//       //           count++;
//       //         }
//       //       }
//       //     }
//       //   }

//       //   if (count > 0) {
//       //     double avgBrightness = static_cast<double>(sum) / count;
//       //     double error = targetBrightness - avgBrightness;
//       //     double proposed =
//       //         longExposure * (1.0 + gain * error / targetBrightness);
//       //     longExposure = std::max(minExposure, std::min(maxExposure,
//       //     proposed));
//       //   }
//       // }
//     }
//   }).detach();
// }

void CapturePipeline::StartGrabbing() {
  if (!camera.camera) {
    std::cerr << "Camera is not initialized." << std::endl;
    return;
  }
  GenApi::INodeMap& nodemap = camera.camera->GetNodeMap();
  Pylon::CEnumParameter(nodemap, "TriggerSelector").SetValue("FrameStart");
  Pylon::CEnumParameter(nodemap, "TriggerMode").SetValue("On");
  Pylon::CEnumParameter(nodemap, "TriggerSource").SetValue("Software");

  camera.camera->StartGrabbing(Pylon::GrabStrategy_OneByOne,
                               Pylon::EGrabLoop::GrabLoop_ProvidedByUser);

  std::cout << "Starting camera grabbing..." << std::endl;

  std::thread([this]() {
    GLInit();
    notifyTextureReady();

    std::vector<double> exposureLevels = {2000.0, 16000.0};
    size_t exposureIndex = 0;
    GenApi::INodeMap& nodemap = camera.camera->GetNodeMap();

    while (camera.camera->IsGrabbing()) {
      // Set new exposure
      double exposure = exposureLevels[exposureIndex];
      exposureIndex = (exposureIndex + 1) % exposureLevels.size();
      Pylon::CFloatParameter(nodemap, "ExposureTime").TrySetValue(exposure);
      std::cout << "Set exposure to: " << exposure << "us" << std::endl;

      camera.camera->WaitForFrameTriggerReady(5000,
                                              Pylon::TimeoutHandling_Return);
      camera.camera->ExecuteSoftwareTrigger();
      Pylon::CGrabResultPtr grabResult;
      if (!camera.camera->RetrieveResult(5000, grabResult,
                                         Pylon::TimeoutHandling_Return)) {
        continue;
      }
      std::cout << "image grabbed" << std::endl;

      if (!grabResult->GrabSucceeded()) {
        std::cerr << "Error grabbing image: "
                  << grabResult->GetErrorDescription() << std::endl;
        continue;
      }
      OnImageGrabbed(grabResult);
      std::cout << "finish processing frame" << std::endl;
    }
  }).detach();
}

void CapturePipeline::notifyTextureReady() {
  // Pass 'this' pointer to main thread callback
  g_idle_add(
      [](void* data) -> gboolean {
        CapturePipeline* self = static_cast<CapturePipeline*>(data);
        std::cout << "Texture is ready" << std::endl;
        self->camera.emitTextureId(self->get_texture_id());
        return G_SOURCE_REMOVE;  // remove source after running once
      },
      this);
}

void CapturePipeline::GLInit() {
  FlView* fl_view = FL_VIEW(fl_plugin_registrar_get_view(m_fl_registrar));
  GdkWindow* window = gtk_widget_get_parent_window(GTK_WIDGET(fl_view));
  m_gl_context = gdk_window_create_gl_context(window, NULL);
  gdk_gl_context_make_current(m_gl_context);
  std::cout << "[DEBUG] Created and made current GL context." << std::endl;

  const int width = camera.width;
  const int height = camera.height;
  std::cout << "[DEBUG] Camera resolution: " << width << "x" << height
            << std::endl;

  // 1. Create PBO ring buffer
  m_ring_buffer_index = 0;
  glGenBuffers(RING_BUFFER_SIZE, m_pbo_ring_buffer);
  for (size_t i = 0; i < RING_BUFFER_SIZE; ++i) {
    glBindBuffer(GL_PIXEL_PACK_BUFFER, m_pbo_ring_buffer[i]);
    glBufferData(GL_PIXEL_PACK_BUFFER, width * height * 3, nullptr,
                 GL_STREAM_READ);
    std::cout << "[DEBUG] Created PBO buffer ID: " << m_pbo_ring_buffer[i]
              << std::endl;
  }
  glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);

  glGenTextures(RING_BUFFER_SIZE, m_exposure_textures);
  for (int i = 0; i < RING_BUFFER_SIZE; ++i) {
    glBindTexture(GL_TEXTURE_2D, m_exposure_textures[i]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  }
  glBindTexture(GL_TEXTURE_2D, 0);

  // 2. Create Motion Mask Texture
  // glGenTextures(1, &m_motion_mask_texture);
  // glBindTexture(GL_TEXTURE_2D, m_motion_mask_texture);
  // glTexImage2D(GL_TEXTURE_2D, 0, GL_R8, width, height, 0, GL_RED,
  //              GL_UNSIGNED_BYTE, nullptr);
  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // std::cout << "[DEBUG] Created motion mask texture ID: "
  //           << m_motion_mask_texture << std::endl;

  // 3. Create HDR Fusion Shader Program
  m_hdr_fusion_shader_program = createHDRShaderProgram();
  std::cout << "[DEBUG] Created HDR fusion shader program ID: "
            << m_hdr_fusion_shader_program << std::endl;

  float quadVertices[] = {
      // pos     // tex
      -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, -1.0f, 1.0f, 0.0f,
      -1.0f, 1.0f,  0.0f, 1.0f, 1.0f, 1.0f,  1.0f, 1.0f,
  };

  glGenVertexArrays(1, &m_hdr_fusion_vao);
  glGenFramebuffers(1, &m_hdr_fusion_fbo);
  glBindVertexArray(m_hdr_fusion_vao);
  glBindBuffer(GL_ARRAY_BUFFER, m_hdr_fusion_vbo);
  glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices,
               GL_STATIC_DRAW);

  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)0);
  glEnableVertexAttribArray(1);
  glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float),
                        (void*)(2 * sizeof(float)));

  glBindVertexArray(0);
  std::cout << "[DEBUG] Created HDR fusion VAO: " << m_hdr_fusion_vao
            << ", VBO: " << m_hdr_fusion_vbo << std::endl;

  // 4. Create Tone Mapping Shader Program
  // TODO: Add debug print here when implemented

  // 5. Create Mono Shader Program
  // m_mono_shader_program = createMonoShaderProgram();
  // std::cout << "[DEBUG] Created Mono shader program ID: "
  //           << m_mono_shader_program << std::endl;

  // float quadVerticesMono[] = {
  //     // pos     // tex
  //     -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, -1.0f, 1.0f, 0.0f,
  //     -1.0f, 1.0f,  0.0f, 1.0f, 1.0f, 1.0f,  1.0f, 1.0f,
  // };

  // glGenVertexArrays(1, &m_mono_vao);
  // glGenBuffers(1, &m_mono_vbo);
  // glBindVertexArray(m_mono_vao);
  // glBindBuffer(GL_ARRAY_BUFFER, m_mono_vbo);
  // glBufferData(GL_ARRAY_BUFFER, sizeof(quadVerticesMono), quadVerticesMono,
  //              GL_STATIC_DRAW);

  // glEnableVertexAttribArray(0);
  // glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float),
  // (void*)0); glEnableVertexAttribArray(1); glVertexAttribPointer(1, 2,
  // GL_FLOAT, GL_FALSE, 4 * sizeof(float),
  //                       (void*)(2 * sizeof(float)));

  // glBindVertexArray(0);
  // std::cout << "[DEBUG] Created Mono VAO: " << m_mono_vao
  //           << ", VBO: " << m_mono_vbo << std::endl;

  // 6. Create Output Texture
  glGenTextures(1, &m_output_texture);
  glBindTexture(GL_TEXTURE_2D, m_output_texture);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, width, height, 0, GL_RGB,
               GL_UNSIGNED_BYTE, nullptr);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  std::cout << "[DEBUG] Created output texture ID: " << m_output_texture
            << std::endl;

  // 7. Wrap output texture for Flutter
  m_fl_texture =
      fl_lightx_texture_gl_new(GL_TEXTURE_2D, m_output_texture, width, height);
  m_fl_texture_name = m_output_texture;
  fl_texture_registrar_register_texture(m_fl_texture_registrar,
                                        FL_TEXTURE(m_fl_texture));
  fl_texture_registrar_mark_texture_frame_available(m_fl_texture_registrar,
                                                    FL_TEXTURE(m_fl_texture));
  std::cout << "[DEBUG] Registered and marked Flutter texture frame available "
               "for texture ID: "
            << m_output_texture << std::endl;
}

void CapturePipeline::StopGrabbing() {}
void CapturePipeline::OnImageGrabbed(const Pylon::CGrabResultPtr& grabResult) {
  if (!grabResult || !grabResult->GrabSucceeded()) {
    std::cerr << "[DEBUG] Error grabbing image: "
              << (grabResult ? grabResult->GetErrorDescription() : "No result")
              << std::endl;
    return;
  }

  const int width = grabResult->GetWidth();
  const int height = grabResult->GetHeight();
  const uint8_t* data = static_cast<const uint8_t*>(grabResult->GetBuffer());
  if (!data) {
    std::cerr << "[DEBUG] No image data available." << std::endl;
    return;
  }

  gdk_gl_context_make_current(m_gl_context);

  const int bufferIndex = m_ring_buffer_index;
  const int nextIndex = (m_ring_buffer_index + 1) % RING_BUFFER_SIZE;

  GLuint pbo = m_pbo_ring_buffer[bufferIndex];
  GLuint texture = m_exposure_textures[bufferIndex];

  glBindBuffer(GL_PIXEL_UNPACK_BUFFER, pbo);
  glBufferData(GL_PIXEL_UNPACK_BUFFER, width * height * 3, nullptr,
               GL_STREAM_DRAW);

  void* ptr = glMapBufferRange(GL_PIXEL_UNPACK_BUFFER, 0, width * height * 3,
                               GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
  if (ptr) {
    std::memcpy(ptr, data, width * height * 3);
    glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER);
  } else {
    std::cerr << "[ERROR] Failed to map PBO" << std::endl;
  }

  // Upload from PBO to texture (allocated only once elsewhere)
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB,
                  GL_UNSIGNED_BYTE, nullptr);
  glBindTexture(GL_TEXTURE_2D, 0);
  glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);

  std::cout << "[DEBUG] Uploaded image data to texture index " << bufferIndex
            << std::endl;

  m_ring_buffer_index = nextIndex;

  // --- HDR Shader Pass ---
  glBindFramebuffer(GL_FRAMEBUFFER, m_hdr_fusion_fbo);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D,
                         m_output_texture, 0);

  if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    std::cerr << "[ERROR] Framebuffer not complete." << std::endl;
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    return;
  }

  glViewport(0, 0, width, height);
  glUseProgram(m_hdr_fusion_shader_program);

  const char* uniformNames[] = {"texLow", "texMidLow"};
  for (int i = 0; i < 2; ++i) {
    glActiveTexture(GL_TEXTURE0 + i);
    glBindTexture(GL_TEXTURE_2D, m_exposure_textures[i]);
    GLint loc =
        glGetUniformLocation(m_hdr_fusion_shader_program, uniformNames[i]);
    glUniform1i(loc, i);
  }

  glBindVertexArray(m_hdr_fusion_vao);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

  // Cleanup
  glBindVertexArray(0);
  for (int i = 0; i < 2; ++i) {
    glActiveTexture(GL_TEXTURE0 + i);
    glBindTexture(GL_TEXTURE_2D, 0);
  }
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
  glUseProgram(0);

  // Notify Flutter
  glFlush();
  fl_texture_registrar_mark_texture_frame_available(m_fl_texture_registrar,
                                                    FL_TEXTURE(m_fl_texture));
}

int64_t CapturePipeline::get_texture_id() {
  if (!m_fl_texture) {
    std::cerr << "Texture is null" << std::endl;
    return -1;
  }
  return fl_texture_get_id(FL_TEXTURE(m_fl_texture));
}

void CapturePipeline::OnNewFrame() {}

GLuint CapturePipeline::compileShader(GLenum type, const char* src) {
  GLuint shader = glCreateShader(type);
  glShaderSource(shader, 1, &src, nullptr);
  glCompileShader(shader);
  GLint success;
  glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
  if (!success) {
    char log[512];
    glGetShaderInfoLog(shader, 512, nullptr, log);
    std::cerr << "Shader compile error: " << log << std::endl;
  }
  return shader;
}

GLuint CapturePipeline::createMonoShaderProgram() {
  const char* vertexSrc = R"(
    #version 300 es
    precision mediump float;
    layout (location = 0) in vec2 position;
    layout (location = 1) in vec2 texCoord;
    out vec2 TexCoords;
    void main() {
      TexCoords = texCoord;
      gl_Position = vec4(position, 0.0, 1.0);
    }
  )";

  const char* fragmentSrc = R"(
    #version 300 es
    precision mediump float;
    in vec2 TexCoords;
    out vec4 FragColor;
    uniform sampler2D monoTexture;
    void main() {
      float gray = texture(monoTexture, TexCoords).r;
      FragColor = vec4(gray, gray, gray, 1.0);  // convert mono to RGB
    }
  )";

  GLuint vs = compileShader(GL_VERTEX_SHADER, vertexSrc);
  GLuint fs = compileShader(GL_FRAGMENT_SHADER, fragmentSrc);

  GLuint program = glCreateProgram();
  glAttachShader(program, vs);
  glAttachShader(program, fs);
  glLinkProgram(program);

  GLint success;
  glGetProgramiv(program, GL_LINK_STATUS, &success);
  if (!success) {
    char log[512];
    glGetProgramInfoLog(program, 512, nullptr, log);
    std::cerr << "Shader program link error: " << log << std::endl;
  }

  glDeleteShader(vs);
  glDeleteShader(fs);

  return program;
}

GLuint CapturePipeline::createHDRShaderProgram() {
  const char* vertexSrc = R"(
    #version 300 es
    precision mediump float;
    layout (location = 0) in vec2 position;
    layout (location = 1) in vec2 texCoord;
    out vec2 TexCoords;
    void main() {
      TexCoords = texCoord;
      gl_Position = vec4(position, 0.0, 1.0);
    }
  )";

  const char* fragmentSrc = R"(
    #version 300 es
    precision mediump float;
    in vec2 TexCoords;
    out vec4 FragColor;

    uniform sampler2D texLow;
    uniform sampler2D texMidLow;

    void main() {
      vec3 colorLow = texture(texLow, TexCoords).rgb;
      vec3 colorMidLow = texture(texMidLow, TexCoords).rgb;

      // Simple exposure fusion strategy: weighted average (weights can be adjusted)
      float w1 = 0.2;
      float w2 = 0.8;

      vec3 hdr = (colorLow * w1 + colorMidLow * w2) / (w1 + w2);
      FragColor = vec4(hdr, 1.0);
    }
  )";

  GLuint vs = compileShader(GL_VERTEX_SHADER, vertexSrc);
  GLuint fs = compileShader(GL_FRAGMENT_SHADER, fragmentSrc);

  GLuint program = glCreateProgram();
  glAttachShader(program, vs);
  glAttachShader(program, fs);
  glLinkProgram(program);

  GLint success;
  glGetProgramiv(program, GL_LINK_STATUS, &success);
  if (!success) {
    char log[512];
    glGetProgramInfoLog(program, 512, nullptr, log);
    std::cerr << "Shader program link error: " << log << std::endl;
  }

  glDeleteShader(vs);
  glDeleteShader(fs);

  return program;
}
