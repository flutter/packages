#include "camera_texture_image_event_handler.h"

#include <GLES3/gl3.h>

#include <chrono>

G_DEFINE_TYPE(FlMyTextureGL, fl_my_texture_gl, fl_texture_gl_get_type())

static gboolean fl_my_texture_gl_populate(FlTextureGL* texture,
                                          uint32_t* target, uint32_t* name,
                                          uint32_t* width, uint32_t* height,
                                          GError** error) {
  FlMyTextureGL* f = (FlMyTextureGL*)texture;
  *target = f->target;
  *name = f->name;
  *width = f->width;
  *height = f->height;
  return true;
}

FlMyTextureGL* fl_my_texture_gl_new(uint32_t target, uint32_t name,
                                    uint32_t width, uint32_t height) {
  auto r = FL_MY_TEXTURE_GL(g_object_new(fl_my_texture_gl_get_type(), nullptr));
  r->target = target;
  r->name = name;
  r->width = width;
  r->height = height;
  return r;
}

static void fl_my_texture_gl_class_init(FlMyTextureGLClass* klass) {
  FL_TEXTURE_GL_CLASS(klass)->populate = fl_my_texture_gl_populate;
}

static void fl_my_texture_gl_init(FlMyTextureGL* self) {}

CameraTextureImageEventHandler::CameraTextureImageEventHandler(
    const Camera& camera, FlPluginRegistrar* registrar)
    : camera(camera),
      m_registrar(registrar),
      m_texture_registrar(
          fl_plugin_registrar_get_texture_registrar(registrar)) {}

CameraTextureImageEventHandler ::~CameraTextureImageEventHandler() {
  if (m_texture) {
    glDeleteTextures(1, &m_texture_name);
    fl_texture_registrar_unregister_texture(m_texture_registrar,
                                            FL_TEXTURE(m_texture));
    g_object_unref(m_texture);
  }
}

int64_t CameraTextureImageEventHandler::get_texture_id() {
  if (!m_texture) {
    std::cerr << "Texture is null" << std::endl;
    return -1;
  }
  return fl_texture_get_id(FL_TEXTURE(m_texture));
}

GLuint compileShader(GLenum type, const char* src) {
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

GLuint createShaderProgram() {
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

void CameraTextureImageEventHandler::OnImageEventHandlerRegistered(
    Pylon::CInstantCamera& _) {
  FlView* fl_view = FL_VIEW(fl_plugin_registrar_get_view(m_registrar));
  GdkWindow* window = gtk_widget_get_parent_window(GTK_WIDGET(fl_view));
  m_gl_context = gdk_window_create_gl_context(window, NULL);
  gdk_gl_context_make_current(m_gl_context);

  const int width = camera.width;
  const int height = camera.height;

  // 1. Create input texture (raw camera frame)
  glGenTextures(1, &m_input_texture);
  glBindTexture(GL_TEXTURE_2D, m_input_texture);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, width, height, 0, GL_RED,
               GL_UNSIGNED_BYTE, nullptr);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  // 2. Create output texture (post-shader result)
  glGenTextures(1, &m_output_texture);
  glBindTexture(GL_TEXTURE_2D, m_output_texture);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, width, height, 0, GL_RGB,
               GL_UNSIGNED_BYTE, nullptr);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  // 3. Create framebuffer and attach output texture
  glGenFramebuffers(1, &m_fbo);
  glBindFramebuffer(GL_FRAMEBUFFER, m_fbo);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D,
                         m_output_texture, 0);

  if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    std::cerr << "Framebuffer not complete!" << std::endl;
  }

  // 4. Create shader program
  m_shader_program = createShaderProgram();

  // 5. Create fullscreen quad VAO/VBO
  float quadVertices[] = {
      // pos     // tex
      -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, -1.0f, 1.0f, 0.0f,
      -1.0f, 1.0f,  0.0f, 1.0f, 1.0f, 1.0f,  1.0f, 1.0f,
  };

  glGenVertexArrays(1, &m_vao);
  glGenBuffers(1, &m_vbo);
  glBindVertexArray(m_vao);
  glBindBuffer(GL_ARRAY_BUFFER, m_vbo);
  glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices,
               GL_STATIC_DRAW);
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)0);
  glEnableVertexAttribArray(1);
  glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float),
                        (void*)(2 * sizeof(float)));

  // 6. Wrap output texture for Flutter
  m_texture =
      fl_my_texture_gl_new(GL_TEXTURE_2D, m_output_texture, width, height);
  fl_texture_registrar_register_texture(m_texture_registrar,
                                        FL_TEXTURE(m_texture));
  fl_texture_registrar_mark_texture_frame_available(m_texture_registrar,
                                                    FL_TEXTURE(m_texture));
  camera.emitTextureId(get_texture_id());
}

void CameraTextureImageEventHandler::OnImageEventHandlerDeregistered(
    Pylon::CInstantCamera& _) {
  camera.emitTextureId(-1);
}

void CameraTextureImageEventHandler::OnImageGrabbed(
    Pylon::CInstantCamera& _, const Pylon::CGrabResultPtr& ptr) {
  if (!m_texture || !ptr->GrabSucceeded()) {
    std::cerr << "Error: Grab failed or texture not ready." << std::endl;
    return;
  }

  gdk_gl_context_make_current(m_gl_context);

  const int width = ptr->GetWidth();
  const int height = ptr->GetHeight();

  if (ptr->GetPixelType() == Pylon::PixelType_Mono8) {
    // Upload to input texture (single channel)
    glBindTexture(GL_TEXTURE_2D, m_input_texture);

    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RED,
                    GL_UNSIGNED_BYTE, ptr->GetBuffer());

    // Use shader to render to output texture via FBO
    glBindFramebuffer(GL_FRAMEBUFFER, m_fbo);

    glViewport(0, 0, width, height);
    glUseProgram(m_shader_program);

    glBindVertexArray(m_vao);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_input_texture);
    glUniform1i(glGetUniformLocation(m_shader_program, "monoTexture"), 0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);  // unbind FBO
  } else {
    // RGB format: write directly to output texture
    glBindTexture(GL_TEXTURE_2D, m_output_texture);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB,
                    GL_UNSIGNED_BYTE, ptr->GetBuffer());
  }

  glFlush();
  // Mark the output texture as new frame available for Flutter
  fl_texture_registrar_mark_texture_frame_available(m_texture_registrar,
                                                    FL_TEXTURE(m_texture));
}
