#!/bin/sh
set -eux

PRJ_ROOT="$( cd "$(dirname "$0")" ; pwd -P)"
BUILD_ROOT=$PRJ_ROOT/build
PYTORCH_ROOT="${PYTORCH_ROOT:-$PRJ_ROOT/pytorch}"

# Check PyTorch source folder
if [ ! -d "$PYTORCH_ROOT" ]; then
  echo "PyTorch src folder doesn't exist: $PYTORCH_ROOT. Downloading..."
  echo "You can use existing PyTorch src by 'export PYTORCH_ROOT=<path>'"
  mkdir -p "$PYTORCH_ROOT"
  git clone --recursive https://github.com/pytorch/pytorch "$PYTORCH_ROOT"
else
  echo "Using PyTorch source code at: $PYTORCH_ROOT"
fi

# Check PyTorch mobile build (host toolchain + mobile build options)
PYTORCH_MOBILE=$PYTORCH_ROOT/build_mobile/install
if [ ! -d "$PYTORCH_MOBILE" ]; then
  echo "Building PyTorch mobile..."
  cd $PYTORCH_ROOT
  scripts/build_mobile.sh
else
  echo "Using PyTorch mobile library at: $PYTORCH_MOBILE"
fi

# Build demo project with host toolchain
rm -rf $BUILD_ROOT && mkdir $BUILD_ROOT && cd $BUILD_ROOT

cmake .. \
-DCMAKE_PREFIX_PATH=$PYTORCH_MOBILE \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=install

make

echo "Build succeeded!"
echo
echo "Run binary:"
echo "build/Predictor mobilenetv2.pt"
