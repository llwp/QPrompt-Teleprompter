#!/bin/bash

#**************************************************************************
#
# QPrompt
# Copyright (C) 2024 Javier O. Cordero Pérez
#
# This file is part of QPrompt.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#**************************************************************************

cat << EOF
usage: $0 <CMAKE_BUILD_TYPE> <CMAKE_PREFIX_PATH> [<QT_MAJOR_VERSION> | ] [CLEAR | CLEAR_ALL]

Defaults:
 * CMAKE_BUILD_TYPE: "Release"
 * CMAKE_PREFIX_PATH: "~/Qt/6.7.0/gcc_64/"
 * QT_MAJOR_VERSION: 6

Setup script for building QPrompt
This script assumes you've already installed the following dependencies:
 * Git
 * CMake
 * Qt 6 Open Source
EOF

source "/home/javier/Software/emsdk/emsdk_env.sh"
EMROOT="/home/javier/Software/emsdk/upstream/emscripten"

CMAKE_BUILD_TYPE=$1
if [ "$CMAKE_BUILD_TYPE" == "" ]
        then CMAKE_BUILD_TYPE="Release"
fi
CMAKE_PREFIX_PATH=$2
if [ "$CMAKE_PREFIX_PATH" == "" ]
        then CMAKE_PREFIX_PATH="~/Qt/6.7.0/wasm_multithread"
fi
QT_MAJOR_VERSION=$3
if [ "$QT_MAJOR_VERSION" == "" ]
        then QT_MAJOR_VERSION=6
fi
CLEAR_ARG="${@: -1}"
if [ "$CLEAR_ARG" == "CLEAR" ]
    then
    CLEAR=true
    CLEAR_ALL=false
elif [ "$CLEAR_ARG" == "CLEAR_ALL" ]
    then
    CLEAR=true
    CLEAR_ALL=true
else
    CLEAR=false
    CLEAR_ALL=false
fi

CLEAR_ALL=true

# Constants
ECM_ADDITIONAL_FIND_ROOT_PATH="/home/javier/Development/Teleprompters/qprompt/QPrompt/build"
CMAKE_FIND_ROOT_PATH="/home/javier/Development/Teleprompters/qprompt/QPrompt/build"
CMAKE_INSTALL_PREFIX="/home/javier/Development/Teleprompters/qprompt/QPrompt/build/dist"
ECM_DIR="${CMAKE_INSTALL_PREFIX}/share/ECM/cmake"
# QT_INSTALL_PREFIX="~/Qt/6.7.0/wasm_multithread"
# QT_INSTALL_PREFIX="~/Qt/6.7.0/wasm_multithread/bin/qmake"

echo "Build directory is ./build"
if $CLEAR_ALL # QPrompt and dependencies
    then
    rm -dRf ./build ./install
elif $CLEAR # QPrompt
    then
    rm -dRf ./build
fi
mkdir -p build install

# echo "Downloading git submodules"
# git submodule update --init --recursive

echo "Extra CMake Modules"/cmake/Modules/Platform/
if $CLEAR_ALL
    then
    rm -dRf ./3rdparty/extra-cmake-modules/build
fi
emcmake cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DBUILD_HTML_DOCS=OFF -DBUILD_MAN_DOCS=OFF -DBUILD_TESTING=OFF -DCMAKE_TOOLCHAIN_FILE=/home/javier/Software/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -B ./3rdparty/extra-cmake-modules/build ./3rdparty/extra-cmake-modules/
emake make ./3rdparty/extra-cmake-modules/build
cmake --install ./3rdparty/extra-cmake-modules/build

echo "$ECM_DIR"

# -DCMAKE_PREFIX_PATH "${PROJECT_SOURCE_DIR}/build/CMakeFiles/pkgRedirects")
# CMAKE_PREFIX_PATH=~/Qt/6.7.0/wasm_multithread/lib/cmake/Qt6Core:$CMAKE_PREFIX_PATH
CMAKE_MODULE_PATH=$CMAKE_PREFIX_PATH
# Qt6Core_DIR=~/Qt/6.7.0/wasm_multithread/lib/cmake/Qt6Core/

# KDE Frameworks
# for dependency in ./3rdparty/k*; do
for dependency in ./3rdparty/kcoreaddons; do
    echo $dependency
    if $CLEAR_ALL
    then
        rm -dRf $dependency/build
    fi
    /home/javier/Qt/6.7.0/wasm_multithread/bin/qt-cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DECM_DIR=$ECM_DIR -DQt6Core_DIR=$Qt6Core_DIR -DLIB_INSTALL_DIR=$QT_INSTALL_PREFIX -DKF_IGNORE_PLATFORM_CHECK=ON -DCMAKE_TOOLCHAIN_FILE=/home/javier/Software/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -B $dependency/build $dependency
    /home/javier/Qt/6.7.0/wasm_multithread/bin/qt-cmake --build $dependency/build
    /home/javier/Qt/6.7.0/wasm_multithread/bin/qt-cmake --install $dependency/build
done

# echo "QPrompt"
# emcmake cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DECM_KDE_MODULE_DIR=$ECM_DIR -DCMAKE_TOOLCHAIN_FILE=/home/javier/Software/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -B ./build .
# emake make ./build
# cmake --install ./build
