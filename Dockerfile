# Use x86_64 Debian Bullseye as base for cross-compilation
FROM debian:bullseye

# Install build tools and ARM cross-compiler
RUN dpkg --add-architecture armhf \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-utils \
        automake \
        build-essential \
        cmake \
        crossbuild-essential-armhf \
        curl \
        fakeroot \
        git \
        make \
        pkg-config \
        runit \
        sudo \
        symlinks \
        xz-utils \
        # ARM development libraries
        libboost-system-dev:armhf \
        libboost-iostreams-dev:armhf \
        libboost-filesystem-dev:armhf \
        libssl-dev:armhf \
        libcurl4-openssl-dev:armhf \
        zlib1g-dev:armhf \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set up cross-compilation environment variables
ENV HOST=arm-linux-gnueabihf \
    RPXC_ROOT=/rpxc \
    ARCH=arm \
    CROSS_COMPILE=arm-linux-gnueabihf- \
    CC=arm-linux-gnueabihf-gcc \
    CXX=arm-linux-gnueabihf-g++ \
    SYSROOT=/usr/arm-linux-gnueabihf

# Create necessary directories and symlinks
RUN mkdir -p $RPXC_ROOT/bin \
 && mkdir -p /build \
 && ln -sf /usr/bin/arm-linux-gnueabihf-gcc $RPXC_ROOT/bin/arm-linux-gnueabihf-gcc \
 && ln -sf /usr/bin/arm-linux-gnueabihf-g++ $RPXC_ROOT/bin/arm-linux-gnueabihf-g++ \
 && ln -sf /usr/bin/arm-linux-gnueabihf-ar $RPXC_ROOT/bin/arm-linux-gnueabihf-ar \
 && ln -sf /usr/bin/arm-linux-gnueabihf-as $RPXC_ROOT/bin/arm-linux-gnueabihf-as \
 && ln -sf /usr/bin/arm-linux-gnueabihf-ld $RPXC_ROOT/bin/arm-linux-gnueabihf-ld \
 && ln -sf /usr/bin/arm-linux-gnueabihf-ranlib $RPXC_ROOT/bin/arm-linux-gnueabihf-ranlib \
 && ln -sf /usr/bin/arm-linux-gnueabihf-strip $RPXC_ROOT/bin/arm-linux-gnueabihf-strip

ENV PATH=$RPXC_ROOT/bin:$PATH

COPY image/ /

WORKDIR /build
ENTRYPOINT [ "/rpxc/entrypoint.sh" ]
