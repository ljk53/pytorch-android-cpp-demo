# pytorch-android-cpp-demo

Shows how to integrate LibTorch C++ library in Android app.

## Build the project with Android NDK toolchain

### Quick Start

- Install Android NDK: https://developer.android.com/ndk/downloads

- Set Android NDK environment variable:
```
export ANDROID_NDK=...
```

- Run "./build_android.sh"

- The script will try to download and build LibTorch for Android. If you have downloaded / built it yourself, you can set the environment variable "PYTORCH_ROOT" to the location of PyTorch root path.

- You can push and run the executable on your device with "adb" by following the instructions it prints at the end.

### What is this for?

You can use this workflow to test your c++ client code from adb command line directly.

### What is this NOT for?

It doesn't show how to integrate prebuilt PyTorch Android library in your project with gradle. For that purpose you can refer to: https://pytorch.org/mobile/android/. There isn't official LibTorch mobile static library package yet. We might provide one in the future.

It produces uncompressed executable that you can run on your device directly. It doesn't reflect the compressed library size in your APK.

## Build the project with host toolchain

### Quick Start

- Checkout the repo and run "./build.sh".

- After it finishes you can run the binary from host directly.

### The script takes the following steps:

1. It will first try to checkout PyTorch source into 'pytorch' directory.
If you already have PyTorch source checked out. You can set PYTORCH_ROOT environment variable before running the script.

2. Then it will try to build LibTorch c++ static library with mobile build options (no autograd, no backward functions, etc).

3. At last it will build the simple demo project using the LibTorch produced in Step 2.

### What is this for?

Although mobile LibTorch is built from the same codebase as standard LibTorch, it uses different build options to shrink the library size. This script allows you to test your mobile model on host using mobile build options.

If you want to build host applications you should directly use prebuilt PyTorch libraries. The prebuilt PyTorch conda package has dynamic libraries, header files and CMake files. You can follow the tutorial at: https://pytorch.org/tutorials/advanced/cpp_export.html

