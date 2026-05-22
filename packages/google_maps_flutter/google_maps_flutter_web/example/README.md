# Example Structure

This directory contains two example apps:
- latest/ uses an unpinned SDK load, so it will use the latest SDK version.
  This follows the standard recommendation in the package's README.
- 3-64 pins the SDK to 3.64. This is used for integration tests of the
  heatmap support, since heatmaps were removed from the SDK in 3.65.
