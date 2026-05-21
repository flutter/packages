#!/bin/bash
# Copyright 2013 The Flutter Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# This script sets the Android Gradle Plugin (AGP) version for the
# all_packages app created by create_all_packages_app.sh. It modifies
# settings.gradle and gradle-wrapper.properties to use the specified versions.
#
# Usage: set_agp_version.sh <agp_version> <gradle_version>

agp_version="$1"
gradle_version="$2"

if [[ -z "$agp_version" || -z "$gradle_version" ]]; then
  echo "Usage: $0 <agp_version> <gradle_version>"
  exit 1
fi

echo "Setting AGP version to $agp_version with Gradle $gradle_version"

# Update AGP version in settings.gradle of the all_packages app.
settings_file="all_packages/android/settings.gradle"
if [[ -f "$settings_file" ]]; then
  sed -i.bak -E "s/(id \"com\.android\.application\" version \")[^\"]+\"/\1${agp_version}\"/" "$settings_file"
  rm -f "${settings_file}.bak"
  echo "Updated AGP in $settings_file"
else
  echo "ERROR: $settings_file not found. Was create_all_packages_app.sh run?"
  exit 1
fi

# Update Gradle wrapper version.
wrapper_file="all_packages/android/gradle/wrapper/gradle-wrapper.properties"
if [[ -f "$wrapper_file" ]]; then
  sed -i.bak -E "s|distributionUrl=.*|distributionUrl=https\\\\://services.gradle.org/distributions/gradle-${gradle_version}-all.zip|" "$wrapper_file"
  rm -f "${wrapper_file}.bak"
  echo "Updated Gradle version in $wrapper_file"
else
  echo "ERROR: $wrapper_file not found."
  exit 1
fi

echo "Done: AGP=$agp_version, Gradle=$gradle_version"
