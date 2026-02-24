#!/bin/env bash
git clone https://github.com/mustache/spec.git tmp_spec

HEAD_HASH=$(git -C tmp_spec rev-parse HEAD)
UTC_NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

rm -rf specs
mkdir -p specs

exports=""
map_entries=""
for json_file in tmp_spec/specs/*.json; do
  base=$(basename "$json_file" .json)
  base=${base#\~}
  dart_name=${base//-/_}
  const_name=$(echo "$dart_name" | tr '[:lower:]' '[:upper:]')

  {
    echo "const String $const_name = r'''"
    cat "$json_file"
    echo "''';"
  } > "specs/$dart_name.dart"

  exports+="import '$dart_name.dart';"$'\n'
  map_entries+="  '$dart_name': $const_name,"$'\n'
done

{
  echo -n "$exports"
  echo ""
  echo "const Map<String, String> SPECS = {"
  echo -n "$map_entries"
  echo "};"
} > specs/specs.dart

mv tmp_spec/specs/* specs/
rm -rf tmp_spec

echo "Specs commit: $HEAD_HASH" > specs/meta.txt
echo "Specs download date: $UTC_NOW" >> specs/meta.txt
