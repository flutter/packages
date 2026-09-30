// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT LAND: diagnostics for https://github.com/flutter/flutter/issues/193452.
//
// Wraps `google.maps.Map` so every map records its lifecycle events, its div's
// layout, pending tile images and Maps-related network/console activity into
// `window.__gmDiag`. Read from Dart with `window.__gmDiagSnapshot()`.
(function () {
  const t0 = performance.now();
  const now = () => Math.round(performance.now() - t0);
  const diag = (window.__gmDiag = {
    mapsVersion: null,
    installed: null,
    userAgent: navigator.userAgent,
    authFailure: null,
    breadcrumbs: [],
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

  window.__gmDiagBreadcrumb = function (msg) {
    pushCapped(diag.breadcrumbs, { t: now(), msg: String(msg).slice(0, 200) }, 60);
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
  window.addEventListener('unhandledrejection', (e) => {
    pushCapped(
      diag.errors,
      { t: now(), message: 'unhandledrejection: ' + String(e.reason || '').slice(0, 300), src: null },
      50,
    );
  });

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
          firstIdleMs: null,
          firstLaidOutIdleMs: null,
          firstTilesloadedMs: null,
          firstProjectionMs: null,
          firstBoundsMs: null,
          events: {},
          resizes: [],
        };
        pushCapped(diag.maps, record, 30);
        this.__gmDiagRecord = record;
        this.__gmDiagDiv = div;

        for (const name of ['idle', 'tilesloaded', 'projection_changed', 'bounds_changed']) {
          this.addListener(name, () => {
            const t = now();
            const rel = t - record.created;
            const l = layout(div);
            if (name === 'idle') {
              if (record.firstIdleMs === null) record.firstIdleMs = rel;
              if (record.firstLaidOutIdleMs === null && l.connected && l.w > 0 && l.h > 0) {
                record.firstLaidOutIdleMs = rel;
              }
            } else if (name === 'tilesloaded' && record.firstTilesloadedMs === null) {
              record.firstTilesloadedMs = rel;
            } else if (name === 'projection_changed' && record.firstProjectionMs === null) {
              record.firstProjectionMs = rel;
            } else if (name === 'bounds_changed' && record.firstBoundsMs === null) {
              record.firstBoundsMs = rel;
            }
            const events = (record.events[name] = record.events[name] || []);
            if (events.length < 5) events.push({ t, ...l });
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

  function classifyResourceUrl(url) {
    if (url.includes('/maps-api-v3/api/js/') && url.includes('/map.js')) return 'mapJs';
    if (url.includes('/maps-api-v3/api/js/')) return 'mapsModuleJs';
    if (url.includes('GetViewportInfo')) return 'getViewportInfo';
    if (url.includes('AuthenticationService')) return 'authService';
    if (url.includes('StaticMapService')) return 'staticMap';
    if (url.includes('/maps/vt')) return 'vtTile';
    if (url.includes('gen_204')) return 'gen204';
    return 'other';
  }

  // Snapshot of a map's live state, taken when a test gives up waiting.
  window.__gmDiagSnapshot = function () {
    const tileHosts = /googleapis|gstatic|google\.com/;
    const resources = performance
      .getEntriesByType('resource')
      .filter((e) => tileHosts.test(e.name))
      .map((e) => ({
        url: e.name.slice(0, 120),
        fullUrl: e.name,
        start: Math.round(e.startTime - t0),
        dur: Math.round(e.duration),
        size: e.transferSize,
        status: e.responseStatus,
      }));
    const byHost = {};
    const byType = {};
    for (const r of resources) {
      const host = new URL(r.url, location.href).host;
      const s = (byHost[host] = byHost[host] || { n: 0, maxDur: 0, zeroSize: 0, non200: 0 });
      s.n++;
      s.maxDur = Math.max(s.maxDur, r.dur);
      if (!r.size) s.zeroSize++;
      if (r.status && r.status !== 200) s.non200++;

      const type = classifyResourceUrl(r.fullUrl);
      const ts = (byType[type] = byType[type] || { n: 0, maxDur: 0, zeroSize: 0, non200: 0 });
      ts.n++;
      ts.maxDur = Math.max(ts.maxDur, r.dur);
      if (!r.size) ts.zeroSize++;
      if (r.status && r.status !== 200) ts.non200++;
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
      mapsVersion: (window.google && google.maps && google.maps.version) || null,
      authFailure: diag.authFailure,
      installed: diag.installed,
      loadFailure: diag.loadFailure || null,
      online: navigator.onLine,
      breadcrumbs: diag.breadcrumbs.slice(-30),
      maps: diag.maps.slice(-5),
      liveMaps,
      resourcesByHost: byHost,
      resourcesByType: byType,
      slowestResources: resources
        .sort((a, b) => b.dur - a.dur)
        .slice(0, 8)
        .map(({ fullUrl, ...rest }) => rest),
      console: diag.console.slice(-10),
      errors: diag.errors.slice(-10),
    });
  };

  // JS-level watchdog: if any test file hangs for 6 minutes without setting
  // `window.$flutterDriverResult`, populate it with a valid failure response
  // containing the full GM_DIAG snapshot so `flutter drive` exits cleanly with
  // diagnostics instead of hanging for 20 minutes with `Actual: <null>`.
  setTimeout(() => {
    if (window.$flutterDriverResult == null) {
      const snap = window.__gmDiagSnapshot();
      let parsed = {};
      try {
        parsed = JSON.parse(snap);
      } catch (_) {}
      window.$flutterDriverResult = JSON.stringify({
        isError: false,
        response: {
          message: JSON.stringify({
            result: 'false',
            failureDetails: [
              JSON.stringify({
                methodName: 'JS_WATCHDOG_TIMEOUT',
                details: 'GM_DIAG_WATCHDOG: ' + snap,
              }),
            ],
            data: { gm_watchdog: parsed },
          }),
        },
      });
    }
  }, 360000);
})();
