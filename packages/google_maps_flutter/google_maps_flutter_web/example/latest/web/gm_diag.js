// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT LAND: diagnostics for https://github.com/flutter/flutter/issues/193452.
//
// Wraps `google.maps.Map` so every map records its lifecycle events, its div's
// layout, pending tile images and Maps-related network/console activity into
// `window.__gmDiag`. Read from Dart with `JSON.stringify(window.__gmDiag)`.
(function () {
  const t0 = performance.now();
  const now = () => Math.round(performance.now() - t0);
  const diag = (window.__gmDiag = {
    mapsVersion: null,
    installed: null,
    userAgent: navigator.userAgent,
    authFailure: null,
    console: [],
    errors: [],
    maps: [],
  });

  window.gm_authFailure = function () {
    diag.authFailure = now();
  };

  const pushCapped = (list, item, cap) => {
    list.push(item);
    if (list.length > cap) list.shift();
  };

  for (const level of ['error', 'warn']) {
    const original = console[level].bind(console);
    console[level] = function (...args) {
      const text = args.map((a) => String(a)).join(' ');
      if (/google|maps|tile/i.test(text)) {
        pushCapped(diag.console, { t: now(), level, text: text.slice(0, 500) }, 50);
      }
      return original(...args);
    };
  }
  window.addEventListener(
    'error',
    (e) => {
      const target = e.target;
      const src = target && (target.src || target.href);
      pushCapped(
        diag.errors,
        { t: now(), message: String(e.message || ''), src: src ? String(src).slice(0, 200) : null },
        50,
      );
    },
    true,
  );

  // Returns false if the Maps API isn't loaded yet. Idempotent.
  window.__gmDiagInstall = function () {
    if (diag.installed !== null) return true;
    if (!(window.google && google.maps && google.maps.Map)) {
      diag.loadFailure = 'google.maps.Map is not defined';
      return false;
    }
    diag.loadFailure = null;
    diag.mapsVersion = google.maps.version || null;
    installWrapper();
    diag.installed = now();
    return true;
  };

  const layout = (div) => ({
    connected: div.isConnected,
    w: div.offsetWidth,
    h: div.offsetHeight,
  });

  function installWrapper() {
    const OriginalMap = google.maps.Map;
    let nextId = 0;

    class DiagMap extends OriginalMap {
      constructor(div, opts) {
        super(div, opts);
        const record = {
          id: nextId++,
          created: now(),
          layoutAtCreation: layout(div),
          events: {},
          resizes: [],
        };
        pushCapped(diag.maps, record, 30);
        this.__gmDiagRecord = record;
        this.__gmDiagDiv = div;
  
        for (const name of ['idle', 'tilesloaded', 'projection_changed', 'bounds_changed']) {
          this.addListener(name, () => {
            const events = (record.events[name] = record.events[name] || []);
            if (events.length < 5) events.push({ t: now(), ...layout(div) });
          });
        }
        if (window.ResizeObserver) {
          new ResizeObserver(() => {
            if (record.resizes.length < 10) record.resizes.push({ t: now(), ...layout(div) });
          }).observe(div);
        }
      }
    }
    google.maps.Map = DiagMap;
  }
  window.__gmDiagInstall();

  // Snapshot of a map's live state, taken when a test gives up waiting.
  window.__gmDiagSnapshot = function () {
    const tileHosts = /googleapis|gstatic|google\.com/;
    const resources = performance
      .getEntriesByType('resource')
      .filter((e) => tileHosts.test(e.name))
      .map((e) => ({
        url: e.name.slice(0, 120),
        start: Math.round(e.startTime - t0),
        dur: Math.round(e.duration),
        size: e.transferSize,
        status: e.responseStatus,
      }));
    const byHost = {};
    for (const r of resources) {
      const host = new URL(r.url, location.href).host;
      const s = (byHost[host] = byHost[host] || { n: 0, maxDur: 0, zeroSize: 0, non200: 0 });
      s.n++;
      s.maxDur = Math.max(s.maxDur, r.dur);
      if (!r.size) s.zeroSize++;
      if (r.status && r.status !== 200) s.non200++;
    }
    const liveMaps = [];
    document.querySelectorAll('.gm-style').forEach((el) => {
      const imgs = Array.from(el.querySelectorAll('img'));
      const pending = imgs.filter((i) => !i.complete);
      const broken = imgs.filter((i) => i.complete && i.naturalWidth === 0);
      liveMaps.push({
        layout: layout(el.parentElement || el),
        imgs: imgs.length,
        pending: pending.length,
        broken: broken.length,
        pendingSrcs: pending.slice(0, 5).map((i) => i.src.slice(0, 120)),
        canvases: el.querySelectorAll('canvas').length,
      });
    });
    return JSON.stringify({
      t: now(),
      mapsVersion: (google.maps && google.maps.version) || null,
      authFailure: diag.authFailure,
      installed: diag.installed,
      loadFailure: diag.loadFailure || null,
      online: navigator.onLine,
      maps: diag.maps.slice(-5),
      liveMaps,
      resourcesByHost: byHost,
      slowestResources: resources.sort((a, b) => b.dur - a.dur).slice(0, 8),
      console: diag.console.slice(-10),
      errors: diag.errors.slice(-10),
    });
  };
})();
