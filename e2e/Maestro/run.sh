#!/bin/bash
set -euo pipefail

SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 16 Pro}"
WORKSPACE="My Demo App.xcworkspace"
SCHEME="My Demo App"
MAESTRO_DIR="$(cd "$(dirname "$0")" && pwd)"

xcrun simctl boot "$SIMULATOR_NAME" || true
xcrun simctl list devices booted | grep -q "$SIMULATOR_NAME" || { echo "Simulator $SIMULATOR_NAME is not booted"; exit 1; }

rm -rf build
xcodebuild \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
  -derivedDataPath build

APP_PATH="$(find build -name "My Demo App.app" -type d | head -n 1)"
[ -n "$APP_PATH" ] || { echo "Built app not found"; exit 1; }

xcrun simctl install booted "$APP_PATH"

FLOW_FILES=()
while IFS= read -r f; do
  [ -n "$f" ] && FLOW_FILES+=("$f")
done < <(find "$MAESTRO_DIR" -type f \( -name '*.yaml' -o -name '*.yml' \) ! -name 'config.yaml' ! -path '*/pages/*' | sort)

if [ ${#FLOW_FILES[@]} -eq 0 ]; then
  echo "ERROR: no flow files found under $MAESTRO_DIR"
  exit 1
fi

echo "Running ${#FLOW_FILES[@]} flow(s):"
printf '  - %s\n' "${FLOW_FILES[@]}"

ENV_ARGS=()
if [ -f "$MAESTRO_DIR/.env" ]; then
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    ENV_ARGS+=(--env "$key=$value")
  done < "$MAESTRO_DIR/.env"
fi

maestro test "${ENV_ARGS[@]}" "${FLOW_FILES[@]}"
