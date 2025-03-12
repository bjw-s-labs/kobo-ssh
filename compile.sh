#!/usr/bin/env bash
set -e

TOOLCHAIN_IMAGE="ghcr.io/bjw-s-labs/kobo-ssh-toolchain:latest"
DROPBEAR_TAG="DROPBEAR_2025.87"
OPENSSH_TAG="V_9_9_P2"

# Download sources
mkdir -p external

rm -rf external/dropbear
git clone --branch "${DROPBEAR_TAG}" --depth 1 https://github.com/mkj/dropbear.git external/dropbear

rm -rf external/openssh-portable
git clone --branch "${OPENSSH_TAG}" --depth 1 https://github.com/openssh/openssh-portable.git external/openssh-portable

# Compile Dropbear
cat > external/dropbear/localoptions.h<< EOF
#define DROPBEAR_MLKEM768 0
#define DSS_PRIV_FILENAME "/usr/local/dropbear/dss_host_key"
#define RSA_PRIV_FILENAME "/usr/local/dropbear/rsa_host_key"
#define ECDSA_PRIV_FILENAME "/usr/local/dropbear/ecdsa_host_key"
#define ED25519_PRIV_FILENAME "/usr/local/dropbear/ed25519_host_key"
EOF

docker run --platform linux/amd64 -v "${PWD}/external/dropbear:/work" "${TOOLCHAIN_IMAGE}" /bin/bash -c 'cd /work; autoconf; autoheader'
docker run --platform linux/amd64 -v "${PWD}/external/dropbear:/work" "${TOOLCHAIN_IMAGE}" /bin/bash -c 'export PATH="/root/x-tools/arm-kobo-linux-gnueabihf/bin:$PATH"; cd /work; ./configure --host=arm-kobo-linux-gnueabihf --disable-zlib --disable-zlib CC="arm-kobo-linux-gnueabihf"-gcc LD="arm-kobo-linux-gnueabihf"-ld --disable-wtmp --disable-lastlog --disable-syslog --disable-utmpx --disable-utmp --disable-wtmpx --disable-loginfunc --disable-pututxline --disable-pututline --enable-bundled-libtom --disable-pam'
docker run --platform linux/amd64 -v "${PWD}/external/dropbear:/work" "${TOOLCHAIN_IMAGE}" /bin/bash -c 'export PATH="/root/x-tools/arm-kobo-linux-gnueabihf/bin:$PATH"; cd /work; make clean'
docker run --platform linux/amd64 -v "${PWD}/external/dropbear:/work" "${TOOLCHAIN_IMAGE}" /bin/bash -c 'export PATH="/root/x-tools/arm-kobo-linux-gnueabihf/bin:$PATH"; cd /work; make PROGRAMS="dropbear dropbearkey" MULTI=1'

# Compile sftp-server
docker run --platform linux/amd64 -v "${PWD}/external/openssh-portable:/work" "${TOOLCHAIN_IMAGE}" /bin/bash -c 'cd /work; autoconf; autoheader'
docker run --platform linux/amd64 -v "${PWD}/external/openssh-portable:/work" "${TOOLCHAIN_IMAGE}" /bin/bash -c 'export PATH="/root/x-tools/arm-kobo-linux-gnueabihf/bin:$PATH"; cd /work; ./configure --host=arm-kobo-linux-gnueabihf --without-openssl --without-zlib --without-pam --without-xauth CC="arm-kobo-linux-gnueabihf"-gcc LD="arm-kobo-linux-gnueabihf"-ld'
docker run --platform linux/amd64 -v "${PWD}/external/openssh-portable:/work" "${TOOLCHAIN_IMAGE}" /bin/bash -c 'export PATH="/root/x-tools/arm-kobo-linux-gnueabihf/bin:$PATH"; cd /work; make clean'
docker run --platform linux/amd64 -v "${PWD}/external/openssh-portable:/work" "${TOOLCHAIN_IMAGE}" /bin/bash -c 'export PATH="/root/x-tools/arm-kobo-linux-gnueabihf/bin:$PATH"; cd /work; make sftp-server'

# Build KoboRoot.tgz
mkdir -p KoboRoot/usr/bin
mv external/dropbear/dropbearmulti KoboRoot/usr/bin/dropbearmulti
mkdir -p KoboRoot/usr/libexec
mv external/openssh-portable/sftp-server KoboRoot/usr/libexec/sftp-server

mkdir -p dist
tar -cvzf dist/KoboRoot.tgz --exclude='.DS_Store' -C KoboRoot .
