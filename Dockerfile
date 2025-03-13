FROM koreader/kokobo:0.3.6-20.04 AS build
ENV PATH=/usr/local/x-tools/arm-kobo-linux-gnueabihf/bin:$PATH

ARG DROPBEAR_TAG="DROPBEAR_2025.87"
ARG OPENSSH_TAG="V_9_9_P2"

WORKDIR /source
RUN <<EOF
  git clone --branch "${DROPBEAR_TAG}" --depth 1 https://github.com/mkj/dropbear.git dropbear
  git clone --branch "${OPENSSH_TAG}" --depth 1 https://github.com/openssh/openssh-portable.git openssh-portable
EOF

WORKDIR /source/dropbear
COPY <<EOF localoptions.h
#define DROPBEAR_MLKEM768 0
#define DSS_PRIV_FILENAME "/usr/local/dropbear/dss_host_key"
#define RSA_PRIV_FILENAME "/usr/local/dropbear/rsa_host_key"
#define ECDSA_PRIV_FILENAME "/usr/local/dropbear/ecdsa_host_key"
#define ED25519_PRIV_FILENAME "/usr/local/dropbear/ed25519_host_key"
#define SFTPSERVER_PATH "/usr/bin/sftp-server"
EOF

RUN <<EOF
  ./configure --host=arm-kobo-linux-gnueabihf CC="arm-kobo-linux-gnueabihf"-gcc LD="arm-kobo-linux-gnueabihf"-ld --disable-zlib --disable-wtmp --disable-lastlog --disable-syslog --disable-utmpx --disable-utmp --disable-wtmpx --disable-loginfunc --disable-pututxline --disable-pututline --enable-bundled-libtom --disable-pam
  make clean
  make -j PROGRAMS="dropbear dropbearkey"
EOF

WORKDIR /source/openssh-portable
RUN <<EOF
  autoreconf
  ./configure --host=arm-kobo-linux-gnueabihf --without-openssl --without-zlib --without-pam --without-xauth CC="arm-kobo-linux-gnueabihf"-gcc LD="arm-kobo-linux-gnueabihf"-ld
  make clean
  make -j sftp-server
EOF

FROM ubuntu:latest
WORKDIR /output
COPY --chown=root:root KoboRoot /KoboRoot
COPY --chown=root:root --chmod=777 --from=build /source/openssh-portable/sftp-server /KoboRoot/usr/bin/sftp-server
COPY --chown=root:root --chmod=777 --from=build /source/dropbear/dropbear /KoboRoot/usr/bin/dropbear
COPY --chown=root:root --chmod=777 --from=build /source/dropbear/dropbearkey /KoboRoot/usr/bin/dropbearkey

RUN <<EOF
  tar -cvzf KoboRoot.tgz -C /KoboRoot .
  rm -rf /KoboRoot
EOF
