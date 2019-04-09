#!/bin/bash

export BASE_DIR=/data/qt-android/
export ANDROID_NDK=$BASE_DIR/android-ndk-r19
export ANDROID_SDK_ROOT=$BASE_DIR/android-sdk-4333796
export Qt5_android=$BASE_DIR/Qt/5.12.2/android_armv7
export PATH=$ANDROID_SDK_ROOT/platform-tools/:$PATH
export ANT=/usr/bin/ant
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk/
export INSTALL_DIR=/data/devel/sei-mobile/usr
export CMAKE_SYSROOT=$ANDROID_NDK/platforms/android-21/arch-arm/

git submodule init
git submodule update

cd tidy-html5
git apply ../tidy-patch.001
mkdir cmake-build
cd cmake-build
cmake ../ -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../import -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_SYSROOT=$ANDROID_NDK/platforms/android-21/arch-arm -DCMAKE_ANDROID_API=21 -DANDROID_PLATFORM=21
make -j 4 tidy-share
mv libtidy.so ../../
cd ../..
rm -rf tidy-html5/cmake-build
