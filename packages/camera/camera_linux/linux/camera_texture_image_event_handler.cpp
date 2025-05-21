#include "camera_texture_image_event_handler.h"

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
    FlPluginRegistrar* registrar)
    : m_registrar(registrar),
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

void CameraTextureImageEventHandler::OnImageEventHandlerRegistered(
    Pylon::CInstantCamera& camera) {
  FlView* fl_view = FL_VIEW(fl_plugin_registrar_get_view(m_registrar));
  GdkWindow* window = gtk_widget_get_parent_window(GTK_WIDGET(fl_view));
  m_gl_context = gdk_window_create_gl_context(window, NULL);

  // Camera frame size, update if you get dynamic size
  int width = 1920;
  int height = 1080;

  // Create GL texture for the camera preview
  gdk_gl_context_make_current(m_gl_context);
  glGenTextures(1, &m_texture_name);
  glBindTexture(GL_TEXTURE_2D, m_texture_name);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, width, height, 0, GL_RGB,
               GL_UNSIGNED_BYTE, nullptr);

  // Wrap GL texture for Flutter
  m_texture =
      fl_my_texture_gl_new(GL_TEXTURE_2D, m_texture_name, width, height);
  fl_texture_registrar_register_texture(m_texture_registrar,
                                        FL_TEXTURE(m_texture));
  fl_texture_registrar_mark_texture_frame_available(m_texture_registrar,
                                                    FL_TEXTURE(m_texture));
}

void CameraTextureImageEventHandler::OnImageGrabbed(
    Pylon::CInstantCamera& camera, const Pylon::CGrabResultPtr& ptr) {
  if (!m_texture) {
    return;
  }

  static std::chrono::steady_clock::time_point m_last_fps_time;
  static int m_frame_count = 0;

  gdk_gl_context_make_current(m_gl_context);
  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, ptr->GetWidth(), ptr->GetHeight(),
                  GL_RGB, GL_UNSIGNED_BYTE, ptr->GetBuffer());
  glFlush();
  fl_texture_registrar_mark_texture_frame_available(m_texture_registrar,
                                                    FL_TEXTURE(m_texture));

  // Track frame count
  m_frame_count++;
  auto now = std::chrono::steady_clock::now();
  auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(
                     now - m_last_fps_time)
                     .count();

  if (elapsed >= 1000) {  // 1 second has passed
    std::cout << "FPS: " << m_frame_count << std::endl;
    m_frame_count = 0;
    m_last_fps_time = now;
  }

  if (!ptr->GrabSucceeded()) {
    std::cerr << "Error grabbing image" << std::endl;
    return;
  }
}
