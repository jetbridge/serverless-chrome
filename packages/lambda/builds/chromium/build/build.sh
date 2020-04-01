#!/bin/sh
# shellcheck shell=dash

#
# Build Chromium for Amazon Linux.
# Assumes root privileges. Or, more likely, Docker—take a look at
# the corresponding Dockerfile in this directory.
#
# Requires
#
# Usage: ./build.sh
#
# Further documentation: https://github.com/adieuadieu/serverless-chrome/blob/develop/docs/chrome.md
#

set -ex

BUILD_BASE=$(pwd)
VERSION=${VERSION:-master}

printf "LANG=en_US.utf-8\nLC_ALL=en_US.utf-8" >> /etc/environment

# install depot_tools
export PATH="/opt/gtk/bin:$PATH:$BUILD_BASE/depot_tools"

# get chrome src
# mkdir chromium
# cd chromium
# fetch --nohooks --no-history chromium
# cd src

#
# tweak to keep Chrome from crashing after 4-5 Lambda invocations
# see https://github.com/adieuadieu/serverless-chrome/issues/41#issuecomment-340859918
# Thank you, Geert-Jan Brits (@gebrits)!
#
SANDBOX_IPC_SOURCE_PATH="content/browser/sandbox_ipc_linux.cc"

sed -e 's/PLOG(WARNING) << "poll";/PLOG(WARNING) << "poll"; failed_polls = 0;/g' -i "$SANDBOX_IPC_SOURCE_PATH"

# install additional deps
gclient runhooks

# specify build flags
mkdir -p out/Headless && \
  echo 'import("//build/args/headless.gn")' > out/Headless/args.gn && \
  echo 'is_debug = false' >> out/Headless/args.gn && \
  echo 'symbol_level = 0' >> out/Headless/args.gn && \
  echo 'blink_symbol_level = 0' >> out/Headless/args.gn && \
  echo 'is_component_build = false' >> out/Headless/args.gn && \
  echo 'remove_webcore_debug_symbols = true' >> out/Headless/args.gn && \
  echo 'enable_nacl = false' >> out/Headless/args.gn && \
  gn gen out/Headless

# build chromium headless shell
autoninja -C out/Headless headless_shell

cp out/Headless/headless_shell "$BUILD_BASE/bin/headless-chromium-unstripped"

cd "$BUILD_BASE"

# strip symbols
strip -o "$BUILD_BASE/bin/headless-chromium" build/chromium/src/out/Headless/headless_shell

# Use UPX to package headless chromium
# this adds 1-1.5 seconds of startup time so generally
# not so great for use in AWS Lambda so we don't actually use it
# but left here in case someone finds it useful
# yum install -y ucl ucl-devel --enablerepo=epel
# cd build
# git clone https://github.com/upx/upx.git
# cd build/upx
# git submodule update --init --recursive
# make all
# cp "$BUILD_BASE/build/chromium/src/out/Headless/headless_shell" "$BUILD_BASE/bin/headless-chromium-packaged"
# src/upx.out "$BUILD_BASE/bin/headless-chromium-packaged"
