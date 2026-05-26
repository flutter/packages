// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'package:web/web.dart' as web;

@JS('mockVisualizationLibrary')
external void mockVisualizationLibrary();

@JS('restoreVisualizationLibrary')
external void restoreVisualizationLibrary();

/// Extension giving [web.Window] a nullable getter to the custom `MockHeatmapLayer` constructor.
extension MockHeatmapLayerGetter on web.Window {
  @JS('MockHeatmapLayer')
  external JSFunction? get mockHeatmapLayer;
}

/// Injects a robust prototype-based JavaScript mock constructor for HeatmapLayer
/// into the global window context, ensuring property-access tests execute cleanly.
void injectMockHeatmapLayer() {
  if (web.window.mockHeatmapLayer != null) {
    return;
  }

  // Inject a robust mock prototype Javascript class supporting get(), set(),
  // and getter properties (gradient, data, map, options) of MVCObject
  final script = web.document.createElement('script') as web.HTMLScriptElement;
  script.text = '''
    class MockMVCArray {
      constructor() {
        this._array = [];
      }
      getArray() {
        return this._array;
      }
      get array() {
        return this._array;
      }
    }
    class MockHeatmapLayer {
      constructor(options) {
        this._gradient = [];
        this._data = new MockMVCArray();
        this._map = null;
        this._options = {};
        this.setOptions(options);
      }
      setOptions(options) {
        if (!options) return;
        this._options = options;
        if (options.gradient) {
          this._gradient = options.gradient;
        }
        if (options.data) {
          this._data = new MockMVCArray();
          this._data._array = Array.from(options.data);
        }
        if (options.map) {
          this._map = options.map;
        }
      }
      get(key) {
        if (key === 'gradient') return this._gradient;
        if (key === 'data') return this._data;
        if (key === 'map') return this._map;
        return this._options[key];
      }
      get data() {
        return this._data;
      }
      getData() {
        return this._data;
      }
      get map() {
        return this._map;
      }
      set map(value) {
        this._map = value;
      }
      setMap(value) {
        this._map = value;
      }
      getMap() {
        return this._map;
      }
    }
    window.MockHeatmapLayer = MockHeatmapLayer;
    window.mockVisualizationLibrary = function() {
      console.log("mockVisualizationLibrary called! window.google:", window.google);
      if (window.google && window.google.maps) {
        console.log("window.google.maps exists!");
        window.originalMaps = window.google.maps;
        var mapsProxy = new Proxy(window.originalMaps, {
          get: function(target, prop) {
            console.log("Proxy get called for prop:", prop);
            if (prop === "visualization") {
              return {
                HeatmapLayer: window.MockHeatmapLayer
              };
            }
            var val = target[prop];
            if (typeof val === "function") {
              return val.bind(target);
            }
            return val;
          }
        });
        try {
          Object.defineProperty(window.google, "maps", {
            value: mapsProxy,
            configurable: true,
            writable: true
          });
          console.log("defineProperty succeeded!");
        } catch (e) {
          console.error("defineProperty failed:", e);
          window.google.maps = mapsProxy;
        }
        console.log("window.google.maps.visualization:", window.google.maps.visualization);
      } else {
        console.log("window.google or window.google.maps is missing!");
      }
    };
    window.restoreVisualizationLibrary = function() {
      if (window.google && window.originalMaps) {
        try {
          Object.defineProperty(window.google, "maps", {
            value: window.originalMaps,
            configurable: true,
            writable: true
          });
        } catch (e) {
          window.google.maps = window.originalMaps;
        }
      }
    };
  ''';
  web.document.head!.appendChild(script);
}
