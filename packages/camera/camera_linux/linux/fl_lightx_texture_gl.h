
#ifndef FL_LIGHTX_TEXTURE_GL_H_
#define FL_LIGHTX_TEXTURE_GL_H_

#include "flutter_linux/flutter_linux.h"
#include "messages.g.h"

G_DECLARE_FINAL_TYPE(FlLightxTextureGL, fl_lightx_texture_gl, FL,
                     LIGHTX_TEXTURE_GL, FlTextureGL)

struct _FlLightxTextureGL {
  FlTextureGL parent_instance;
  uint32_t target;
  uint32_t name;
  uint32_t width;
  uint32_t height;
};

FlLightxTextureGL* fl_lightx_texture_gl_new(uint32_t target, uint32_t name,
                                            uint32_t width, uint32_t height);

#endif  // FL_LIGHTX_TEXTURE_GL_H_