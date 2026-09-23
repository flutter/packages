// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import {readFile, writeFile, readdir} from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const fixtures = path.join(root, 'test/filters/fixtures');

// These exceptional cases are produced by independent scalar calculations.
// Every other alternative SVG is an explicitly equivalent construction.
function analyticGenerator(name) {
  if (/^convolve_(emboss|edge|bias|negative_bias|alpha_create)_(sRGB|linearRGB)$/.test(name)) return 'convolve_references.py';
  if (/^(diffuse|specular)_(distant|point|spot)_(kernel_x|kernel_y|kernel_four|alpha_ramp)$/.test(name)) return 'lighting_references.py';
  if (/^turbulence_(turbulence|fractalNoise)_(subregion_stitch|clipped_stitch)$/.test(name)) return 'turbulence_references.py';
  return null;
}

export async function referenceSource(name) {
  let input = `${name}.reference.svg`;
  let svg;
  try { svg = await readFile(path.join(fixtures, input), 'utf8'); }
  catch (error) {
    if (error.code !== 'ENOENT') throw error;
    input = `${name}.svg`;
    svg = await readFile(path.join(fixtures, input), 'utf8');
  }
  const generator = analyticGenerator(name);
  const kind = generator && input.endsWith('.reference.svg') ? 'analytic'
    : input.endsWith('.reference.svg') ? 'equivalent-svg' : 'browser';
  return {svg, metadata: {kind, input, ...(kind === 'analytic' ? {generator} : {}),
    ...(svg.includes('data-reference-raster-width') ? {interpolation: 'browser temporary grid'} : {})}};
}

export async function writeReferenceSources() {
  const files = (await readdir(path.join(root, 'test/filters/reference'))).filter(name => name.endsWith('.png')).sort();
  const sources = {};
  for (const file of files) {
    const name = file.slice(0, -4);
    sources[name] = (await referenceSource(name)).metadata;
  }
  await writeFile(path.join(root, 'test/filters/reference/sources.json'), JSON.stringify(sources, null, 2) + '\n');
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  await writeReferenceSources();
}
