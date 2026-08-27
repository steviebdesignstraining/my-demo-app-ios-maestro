#!/bin/bash
set -euo pipefail

SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 16 Pro}"
IOS_VERSION="${IOS_VERSION:-18.6}"
WORKSPACE="${WORKSPACE:-My Demo App.xcworkspace}"
SCHEME="${SCHEME:-My Demo App}"
APP_NAME="${APP_NAME:-My Demo App}"

MAESTRO_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$MAESTRO_DIR/../.." && pwd)"
cd "$REPO_ROOT"

BUILD_DIR="${BUILD_DIR:-build}"
RESULTS_DIR="${RESULTS_DIR:-$BUILD_DIR/maestro-results}"
DEBUG_DIR="${DEBUG_DIR:-$BUILD_DIR/maestro-debug}"
APP_PATH="$BUILD_DIR/Build/Products/Debug-iphonesimulator/$APP_NAME.app"

echo "==> Checking prerequisites"
command -v xcodebuild >/dev/null || { echo "xcodebuild not found"; exit 1; }
command -v xcrun >/dev/null || { echo "xcrun not found"; exit 1; }
command -v maestro >/dev/null || { echo "maestro not found"; exit 1; }

if [ -f "$REPO_ROOT/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$REPO_ROOT/.env"
  set +a
fi

echo "==> Building $SCHEME for $SIMULATOR_NAME / iOS $IOS_VERSION"
rm -rf "$BUILD_DIR"
xcodebuild   -workspace "$WORKSPACE"   -scheme "$SCHEME"   -configuration Debug   -sdk iphonesimulator   -destination "platform=iOS Simulator,name=$SIMULATOR_NAME,OS=$IOS_VERSION"   -derivedDataPath "$BUILD_DIR"   build

if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: Expected app bundle was not found:"
  echo "       $APP_PATH"
  echo "Built .app bundles:"
  find "$BUILD_DIR" -name "*.app" -type d -print || true
  exit 1
fi

echo "==> Booting simulator"
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
xcrun simctl bootstatus "$SIMULATOR_NAME" -b

echo "==> Installing app"
xcrun simctl install booted "$APP_PATH"

echo "==> Running Maestro suite"
mkdir -p "$RESULTS_DIR"
mkdir -p "$DEBUG_DIR"
maestro test   --test-output-dir "$RESULTS_DIR"   --format html-detailed   --output "$BUILD_DIR/maestro-report.html"   --debug-output "$DEBUG_DIR"   "$MAESTRO_DIR"

echo "==> Report: $BUILD_DIR/maestro-report.html"
echo "==> Debug artifacts (screenshots/logs): $DEBUG_DIR"
