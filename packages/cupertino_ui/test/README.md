# Tests for the Cupertino package

Avoid importing the material_ui package in these tests as we're trying to test
the Cupertino package in standalone scenarios.

The material_ui package contains tests for cross-interactions of Material and
Cupertino widgets in hybridized apps.

Some tests may also be replicated in the Material tests when Material reuses
Cupertino components on iOS such as page transitions and text editing.
