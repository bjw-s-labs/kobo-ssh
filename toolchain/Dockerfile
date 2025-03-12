FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive

# Build dependencies
RUN \
  apt-get update -y \
  && dpkg --add-architecture armhf \
  && apt-get update -y \
  && apt-get install -y \
    autoconf \
    autogen \
    automake \
    bison \
    build-essential \
    cmake \
    cross-gcc-dev \
    crossbuild-essential-armhf \
    curl \
    file \
    flex \
    g++-arm-linux-gnueabihf \
    gawk \
    gcc-arm-linux-gnueabihf \
    git \
    gperf \
    help2man \
    libglu1-mesa-dev \
    libncurses-dev \
    libtool \
    libtool-bin \
    libtool-doc \
    libx11-dev \
    libx11-dev \
    libxext-dev \
    libxinerama-dev \
    mesa-common-dev \
    nasm \
    shtool \
    texinfo \
    unzip \
    wget \
    xorg-dev \
  && mkdir -p /crosstool-cfg \
  && mkdir -p /home/crosstooluser/src \
  && mkdir -p /root/src

# Pull in crosstool-ng
RUN \
  git clone https://github.com/NiLuJe/crosstool-ng /crosstool-ng-sources

# Build crosstool-ng
WORKDIR /crosstool-ng-sources
RUN \
  ./bootstrap \
  && ./configure \
  && make \
  && make install

WORKDIR /crosstool-cfg
RUN \
  ct-ng arm-kobo-linux-gnueabihf
RUN \
  echo "CT_EXPERIMENTAL=y\n" >> .config \
  && echo "CT_ALLOW_BUILD_AS_ROOT=y\n" >> .config \
  && echo "CT_ALLOW_BUILD_AS_ROOT_SURE=y\n" >> .config \
  && echo "CT_LOG_PROGRESS_BAR=\"\"\n" >> .config \
  && ct-ng build
