#!/bin/sh

set -e
set -x

dartanalyzer --strong --fatal-warnings ./
pub run test --platform vm
dartfmt -n --set-exit-if-changed ./
