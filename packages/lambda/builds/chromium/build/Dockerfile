#
# Build with:
# docker build --compress -t adieuadieu/chromium-for-amazonlinux-base:62.0.3202.62 --build-arg VERSION=62.0.3202.62 .
#
# Jump into the container with:
# docker run -i -t --rm --entrypoint /bin/bash  adieuadieu/chromium-for-amazonlinux-base
#
# Launch headless Chromium with:
# docker run -d --rm --name headless-chromium -p 9222:9222 adieuadieu/headless-chromium-for-aws-lambda
#

# FROM amazonlinux:2017.03
FROM lambci/lambda:build-provided

# ref: https://chromium.googlesource.com/chromium/src.git/+refs
ARG VERSION
ENV VERSION ${VERSION:-master}

LABEL maintainer="Marco Lüthy <marco.luethy@gmail.com>"
LABEL chromium="${VERSION}"

WORKDIR /

RUN  yum install epel-release -y
RUN  yum install -y \
  git python bzip2 tar pkgconfig atk-devel alsa-lib-devel \
  bison binutils brlapi-devel bluez-libs-devel bzip2-devel cairo-devel \
  cups-devel dbus-devel dbus-glib-devel expat-devel fontconfig-devel \
  freetype-devel gcc-c++ glib2-devel glibc.i686 gperf glib2-devel \
  gtk3-devel java-1.*.0-openjdk-devel libatomic libcap-devel libffi-devel \
  libgcc.i686 libgnome-keyring-devel libjpeg-devel libstdc++.i686 libX11-devel \
  libXScrnSaver-devel libXtst-devel libxkbcommon-x11-devel ncurses-compat-libs \
  nspr-devel nss-devel pam-devel pango-devel pciutils-devel \
  pulseaudio-libs-devel zlib.i686 httpd mod_ssl php php-cli python-psutil wdiff \
  xorg-x11-server-Xvfb glibc-devel

# ADD .gclient /build/chromium/

WORKDIR /build
RUN git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git

ADD build.sh /
WORKDIR /build/chromium
RUN /build/depot_tools/fetch --nohooks --no-history chromium
WORKDIR /build/chromium/src

RUN sh /build.sh

EXPOSE 9222

ENTRYPOINT [ \
  "/bin/headless-chromium", \
  "--disable-dev-shm-usage", \
  "--disable-gpu", \
  "--no-sandbox", \
  "--hide-scrollbars", \
  "--remote-debugging-address=0.0.0.0", \
  "--remote-debugging-port=9222" \
  ]
