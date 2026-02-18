UNSUPPORTED_SPECS=(
    "~dynamic-names"
    "~inheritance"
)

cd test
if [ -d "spec" ]; then
    rm -rf spec
fi
./download-spec.sh
cd ..

UNSUPPORTED_SPEC_ARGS=()

for spec in "${UNSUPPORTED_SPECS[@]}"; do
    UNSUPPORTED_SPEC_ARGS+=("-u=$spec")
done

dart run test/all.dart "${UNSUPPORTED_SPEC_ARGS[@]}"