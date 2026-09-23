# Visual reference provenance

`sources.json` identifies the source for every PNG:

- `browser`: Chrome renders the original fixture SVG directly.
- `equivalent-svg`: Chrome renders an explicit `.reference.svg` construction.
  This tests equivalence or a specified behavior where Chrome handles the original
  primitive differently; it is not a direct browser comparison of the original.
- `analytic`: a listed Python generator computes an independent scalar oracle;
  Chrome only displays/interpolates that result. These cases test the numerical
  specification, not agreement with Chrome's implementation of the primitive.

`browser.json` records the browser used by the latest generation run. The scalar
algorithms are in `tool/{convolve,lighting,turbulence}_references.py`; original and
alternative inputs are kept in `fixtures/`. Tests include the provenance category
in their names. Pixel tolerances are specified by each test and the shared helper.

Regenerate the exceptional analytic inputs with their Python generator, then run
`node tool/filter_goldens.mjs [fixture names]`. To refresh only the provenance
inventory, run `node tool/reference_sources.mjs`. Never regenerate expected PNGs
from the Flutter implementation under test.
