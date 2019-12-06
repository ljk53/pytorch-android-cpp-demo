#!/bin/sh
set -eux

PRJ_ROOT="$( cd "$(dirname "$0")" ; pwd -P)"
BUILD_ROOT=$PRJ_ROOT/build_android
PYTORCH_ROOT="${PYTORCH_ROOT:-$PRJ_ROOT/pytorch}"

# Check ANDROID NDK
if [ -z "$ANDROID_NDK" ]; then
  echo "ANDROID_NDK not set; please set it to the Android NDK directory"
  exit 1
fi

# Check PyTorch source folder
if [ ! -d "$PYTORCH_ROOT" ]; then
  echo "PyTorch src folder doesn't exist: $PYTORCH_ROOT. Downloading..."
  echo "You can use existing PyTorch src by 'export PYTORCH_ROOT=<path>'"
  mkdir -p "$PYTORCH_ROOT"
  git clone --recursive https://github.com/pytorch/pytorch "$PYTORCH_ROOT"
else
  echo "Using PyTorch source code at: $PYTORCH_ROOT"
fi

# Check PyTorch Android build
PYTORCH_ANDROID=$PYTORCH_ROOT/build_android/install
if [ ! -d "$PYTORCH_ANDROID" ]; then
  echo "Building PyTorch Android..."
  cd $PYTORCH_ROOT
  BUILD_PYTORCH_MOBILE=1 scripts/build_android.sh
else
  echo "Using PyTorch Android library at: $PYTORCH_ANDROID"
fi

# Build demo project
rm -rf $BUILD_ROOT && mkdir -p $BUILD_ROOT && cd $BUILD_ROOT

cmake .. \
-DCMAKE_PREFIX_PATH=$PYTORCH_ANDROID \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=install \
-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
-DANDROID_TOOLCHAIN=clang \
-DANDROID_ABI='armeabi-v7a with NEON' \
-DANDROID_NATIVE_API_LEVEL=21 \
-DANDROID_CPP_FEATURES='rtti exceptions' \
-DPYTORCH_ANDROID_PATH="$PYTORCH_ANDROID"

make

echo "Build succeeded!"
echo
echo "Run binary on Android:"
echo "adb push build_android/Predictor mobilenetv2.pt /data/local/tmp"
echo "adb shell 'cd /data/local/tmp; ./Predictor mobilenetv2.pt'"
