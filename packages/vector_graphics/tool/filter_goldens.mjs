// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Regenerate independent SVG references with a dedicated headless Chrome profile.
import {spawn} from 'node:child_process';
import {referenceSource, writeReferenceSources} from './reference_sources.mjs';
import {mkdtemp, readFile, writeFile, rm, readdir} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const fixtures = path.join(root, 'test/filters/fixtures');
const output = path.join(root, 'test/filters/reference');
const profile = await mkdtemp(path.join(tmpdir(), 'vg-filter-goldens-'));
const executable = process.env.CHROME_BINARY ?? '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const chrome = spawn(executable, ['--headless=new', '--disable-gpu', '--no-first-run',
  '--no-default-browser-check', '--remote-debugging-port=0', `--user-data-dir=${profile}`, 'about:blank'],
  {stdio: 'ignore'});
let socket;
try {
  let port;
  for (let attempt = 0; attempt < 100; attempt++) {
    try { port = (await readFile(path.join(profile, 'DevToolsActivePort'), 'utf8')).split('\n')[0]; break; }
    catch { await new Promise(resolve => setTimeout(resolve, 100)); }
  }
  if (!port) throw new Error('Chrome did not start');
  const pages = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
  socket = new WebSocket(pages.find(page => page.type === 'page').webSocketDebuggerUrl);
  await new Promise((resolve, reject) => { socket.onopen = resolve; socket.onerror = reject; });
  let nextId = 0;
  const pending = new Map();
  socket.onmessage = event => {
    const message = JSON.parse(event.data);
    if (!message.id) return;
    const callbacks = pending.get(message.id);
    if (!callbacks) return;
    pending.delete(message.id);
    message.error ? callbacks.reject(new Error(JSON.stringify(message.error))) : callbacks.resolve(message.result);
  };
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = ++nextId;
    const timeout = setTimeout(() => { pending.delete(id); reject(new Error(`CDP timeout: ${method}`)); }, 15000);
    pending.set(id, {resolve: value => {clearTimeout(timeout); resolve(value);}, reject: error => {clearTimeout(timeout); reject(error);}});
    socket.send(JSON.stringify({id, method, params}));
  });
  await send('Page.enable');
  await send('Emulation.setDeviceMetricsOverride', {width: 128, height: 128, deviceScaleFactor: 1, mobile: false});
  await send('Emulation.setDefaultBackgroundColorOverride', {color: {r: 0, g: 0, b: 0, a: 0}});
  const names = process.argv.slice(2);
  const files = names.length ? names.map(name => `${name.replace(/\.svg$/, '')}.svg`) : (await readdir(fixtures)).filter(name => name.endsWith('.svg') && !name.endsWith('.reference.svg')).sort();
  for (const file of files) {
    const {svg} = await referenceSource(file.replace(/\.svg$/, ''));
    await send('Page.navigate', {url: `data:image/svg+xml;base64,${Buffer.from(svg).toString('base64')}`});
    // Wait for document loading, font loading, and two completed paint frames.
    for (let attempt = 0; attempt < 100; attempt++) {
      const result = await send('Runtime.evaluate', {expression: 'document.readyState', returnByValue: true});
      if (result.result.value === 'complete') break;
      await new Promise(resolve => setTimeout(resolve, 20));
    }
    await send('Runtime.evaluate', {expression: 'document.fonts.ready.then(() => new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r))))', awaitPromise: true});
    // Reference-only attributes request a real low-resolution browser filter
    // surface followed by browser image interpolation (kernelUnitLength oracle).
    const rasterWidth = /data-reference-raster-width="(\d+)"/.exec(svg);
    const rasterHeight = /data-reference-raster-height="(\d+)"/.exec(svg);
    if (rasterWidth && rasterHeight) {
      const raster = await send('Page.captureScreenshot', {format: 'png',
        clip: {x: 0, y: 0, width: Number(rasterWidth[1]), height: Number(rasterHeight[1]), scale: 1}});
      const html = `<body style="margin:0;background:transparent"><img style="width:128px;height:128px" src="data:image/png;base64,${raster.data}"></body>`;
      await send('Page.navigate', {url: `data:text/html;base64,${Buffer.from(html).toString('base64')}`});
      for (let attempt = 0; attempt < 100; attempt++) {
        const ready = await send('Runtime.evaluate', {expression: 'document.images.length === 1 && document.images[0].complete', returnByValue: true});
        if (ready.result.value === true) break;
        await new Promise(resolve => setTimeout(resolve, 20));
      }
      await send('Runtime.evaluate', {expression: 'new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)))', awaitPromise: true});
    }
    const screenshot = await send('Page.captureScreenshot', {format: 'png', captureBeyondViewport: false});
    await writeFile(path.join(output, file.replace(/\.svg$/, '.png')), Buffer.from(screenshot.data, 'base64'));
    process.stdout.write(`${file}\n`);
  }
  await writeReferenceSources();
  const version = await send('Browser.getVersion');
  await writeFile(path.join(output, 'browser.json'), JSON.stringify({product: version.product, protocolVersion: version.protocolVersion, width: 128, height: 128, deviceScaleFactor: 1}, null, 2) + '\n');
} finally {
  socket?.close();
  chrome.kill();
  if (chrome.exitCode === null) await new Promise(resolve => chrome.once('exit', resolve));
  await rm(profile, {recursive: true, force: true});
}
