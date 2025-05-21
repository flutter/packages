
#ifndef DMA_BUFFER_FACTORY_H_
#define DMA_BUFFER_FACTORY_H_

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GL/gl.h>
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <fcntl.h>
#include <gbm.h>
#include <unistd.h>

#include <map>
#include <stdexcept>

#include "flutter_linux/flutter_linux.h"
#include "messages.g.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverloaded-virtual"
#pragma clang diagnostic ignored "-Wunused-variable"

#include <pylon/PylonIncludes.h>

#pragma clang diagnostic pop

class DMABufferFactory : public Pylon::IBufferFactory {
 public:
  struct BufferInfo {
    gbm_bo* bo;
    void* mappedAddress;
    intptr_t context;
  };

  DMABufferFactory();

  ~DMABufferFactory() override;

  void AllocateBuffer(size_t bufferSize, void** pCreatedBuffer,
                      intptr_t& bufferContext) override;

  void FreeBuffer(void* pCreatedBuffer, intptr_t bufferContext) override;

  void DestroyBufferFactory() override;

  gbm_bo* get_bo(void* pCreatedBuffer);
  gbm_device* get_gbm_device() { return m_gbmDevice; }

 private:
  gbm_device* m_gbmDevice = nullptr;
  std::map<void*, BufferInfo> buffers = {};
};

#endif  // DMA_BUFFER_FACTORY_H_
