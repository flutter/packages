#include "dma_buffer_factory.h"

DMABufferFactory::DMABufferFactory() {
  m_gbmDevice = gbm_create_device(open("/dev/dri/renderD128", O_RDWR));
  if (!m_gbmDevice) {
    throw std::runtime_error("Failed to create GBM device");
  }
}

DMABufferFactory ::~DMABufferFactory() {
  for (auto& pair : buffers) {
    FreeBuffer(pair.second.mappedAddress, pair.second.context);
  }
  if (m_gbmDevice) {
    close(gbm_device_get_fd(m_gbmDevice));
    gbm_device_destroy(m_gbmDevice);
  }
}

void DMABufferFactory::AllocateBuffer(size_t bufferSize, void** pCreatedBuffer,
                                      intptr_t& bufferContext) {
  const int width = 3840;
  const int height = 2160;
  const int format = GBM_FORMAT_XRGB8888;

  gbm_bo* bo = gbm_bo_create(m_gbmDevice, width, height, format,
                             GBM_BO_USE_LINEAR | GBM_BO_USE_RENDERING);

  if (!bo) {
    throw std::runtime_error("Failed to allocate GBM buffer");
  }

  void* map_data = nullptr;
  uint32_t stride;
  void* addr = gbm_bo_map(bo, 0, 0, width, height, GBM_BO_TRANSFER_WRITE,
                          &stride, &map_data);
  if (!addr) {
    gbm_bo_destroy(bo);
    throw std::runtime_error("Failed to map GBM buffer");
  }

  intptr_t ctx = reinterpret_cast<intptr_t>(map_data);

  BufferInfo info = {bo, addr, ctx};
  buffers[addr] = info;

  *pCreatedBuffer = addr;
  bufferContext = ctx;
}

void DMABufferFactory::FreeBuffer(void* pCreatedBuffer,
                                  intptr_t bufferContext) {
  auto it = buffers.find(pCreatedBuffer);
  if (it != buffers.end()) {
    gbm_bo_unmap(it->second.bo, (void*)bufferContext);
    gbm_bo_destroy(it->second.bo);
    buffers.erase(it);
  }
}

void DMABufferFactory::DestroyBufferFactory() { delete this; }

gbm_bo* DMABufferFactory::get_bo(void* pCreatedBuffer) {
  auto it = buffers.find(pCreatedBuffer);
  if (it != buffers.end()) {
    return it->second.bo;
  }
  return nullptr;
}
