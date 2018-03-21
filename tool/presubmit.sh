#!/bin/sh

set -e
set -x

pub get
dartanalyzer --strong --fatal-warnings ./
pub run test --platform vm
./tool/dart2_test.sh
dartfmt -n --set-exit-if-changed ./
