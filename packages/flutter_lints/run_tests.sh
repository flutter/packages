#!/bin/bash

filecount=`find . -name '*.dart' | wc -l`
if [ $filecount -ne 0 ]
then
  echo 'Dart sources are not allowed in this package:'
  find . -name '*.dart'
  exit 1
fi
