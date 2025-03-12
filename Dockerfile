FROM debian:bookworm

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
    xorg-dev

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

# Set up a temp dir to configure crosstool in
RUN \
  mkdir -p /crosstool-cfg \
  && /crosstool-cfg \
  && mkdir -p /home/crosstooluser/src \
  && ct-ng arm-kobo-linux-gnueabihf

# Set up a temp user for crosstool to use
RUN \
  echo "CT_EXPERIMENTAL=y\n" >> .config \
  && echo "CT_ALLOW_BUILD_AS_ROOT=y\n" >> .config \
  && echo "CT_ALLOW_BUILD_AS_ROOT_SURE=y\n" >> .config \
  && mkdir -p /root/src \
  && ct-ng build
