// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <windows.h>

// Include ABI composition headers for interop with DCOMP surface handle from
// MediaEngine
#include <windows.ui.composition.h>
#include <windows.ui.composition.interop.h>

// Include prior to C++/WinRT Headers
#include <wil/cppwinrt.h>

// C++/WinRT Headers
#include <winrt/Windows.ApplicationModel.Core.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.UI.Composition.h>
#include <winrt/Windows.UI.Core.h>
#include <winrt/Windows.UI.Input.h>

// Direct3D
#include <d3d11.h>

// Windows Implementation Library
#include <wil/resource.h>
#include <wil/result_macros.h>

// MediaFoundation headers
#include <Audioclient.h>
#include <d3d11.h>
#include <mfapi.h>
#include <mferror.h>
#include <mfmediaengine.h>

// STL headers
#include <functional>
#include <memory>

#include "DirectCompositionLayer.h"

using namespace Microsoft::WRL;

namespace ui
{

namespace
{
    winrt::com_ptr<IDCompositionVisual> CreateVisualFromSurfaceHandle(IDCompositionDevice* device, HANDLE surfaceHandle)
    {
        winrt::com_ptr<IDCompositionSurface> surface;
        THROW_IF_FAILED(device->CreateSurfaceFromHandle(surfaceHandle, reinterpret_cast<IUnknown**>(surface.put())));
        winrt::com_ptr<IDCompositionVisual> visual;
        THROW_IF_FAILED(device->CreateVisual(visual.put()));
        THROW_IF_FAILED(visual->SetContent(surface.get()));
        return visual;
    }
} // namespace

DirectCompositionLayer::DirectCompositionLayer(IDCompositionVisual* visual)
{
    m_visual.copy_from(visual);
}

IDCompositionVisual* DirectCompositionLayer::GetVisual() { return m_visual.get(); }

std::shared_ptr<DirectCompositionLayer> DirectCompositionLayer::CreateFromSurface(IDCompositionDevice* device, HANDLE surfaceHandle)
{
    winrt::com_ptr<IDCompositionVisual> visual = CreateVisualFromSurfaceHandle(device, surfaceHandle);
    return std::make_shared<DirectCompositionLayer>(visual.get());
}

} // namespace ui