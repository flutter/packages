git clone https://github.com/mustache/spec.git tmp_spec

HEAD_HASH=$(git -C tmp_spec rev-parse HEAD)
UTC_NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [ -d "specs" ]; then
    rm -rf specs
fi
mkdir -p specs

mv tmp_spec/specs/* specs/
rm -rf tmp_spec

echo "Specs commit: $HEAD_HASH" > specs/meta.txt
echo "Specs download date: $UTC_NOW" >> specs/meta.txt
