// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <windows.h>

#include <tuple>

#include "MediaEngineExtension.h"
#include "MediaFoundationHelpers.h"

#include <d3d11.h>
#include <Dcomp.h>

namespace ui
{

// This class represents a layer in the visual tree. For example, video will be in a separate layer in the visual tree to UI elements such
// as transport controls. This is a wrapper class for the IDCompositionVisual associated with the layer.
class DirectCompositionLayer
{
  public:
    DirectCompositionLayer(IDCompositionVisual* visual);
    virtual ~DirectCompositionLayer() {}
    IDCompositionVisual* GetVisual();

    static std::shared_ptr<DirectCompositionLayer> CreateFromSurface(IDCompositionDevice* device, HANDLE surfaceHandle);

  private:
    winrt::com_ptr<IDCompositionVisual> m_visual;
};

} // namespace ui