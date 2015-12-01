#!/usr/bin/env bash

build_autotools() {
  autoreconf -i
  ./configure --prefix=$PWD/_install
  make install
}

build_cmake() {
  mkdir $PWD/_build && cd $PWD/_build
  cmake .. -GNinja -DCMAKE_INSTALL_PREFIX=$PWD/../_install -DCMAKE_C_FLAGS="-Werror"
  cmake --build . --target install
  ctest -V .
}

build_asan() {
  mkdir $PWD/_build && cd $PWD/_build
  cmake .. -GNinja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$PWD/../_install \
    -DCMAKE_C_FLAGS="-Werror -fsanitize=address,undefined -O1"
  cmake --build . --target install
  ctest -V .
}

build_tsan() {
  mkdir $PWD/_build && cd $PWD/_build
  cmake .. -GNinja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$PWD/../_install \
    -DCMAKE_C_FLAGS="-Werror -fsanitize=thread,undefined -O1"
  cmake --build . --target install
  ctest -V .
}

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {autotools|cmake|asan|tsan}"
  exit 1
fi

set -e  # exit on error.
set -x  # echo commands.

case $TRAVIS_OS_NAME in
osx)
  # This prints out a long list of updated packages, which isn't useful.
  brew update > /dev/null
  brew install popt ninja
  ;;
esac

eval "build_$1"
