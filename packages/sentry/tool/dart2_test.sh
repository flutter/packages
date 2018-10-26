#!/bin/sh
# Temporary workaround until Pub supports --preview-dart-2 flag
set -e
set -x
for filename in test/*_test.dart; do
    dart --preview-dart-2 --enable_asserts "$filename"
done
