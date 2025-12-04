# Use ARM32v6 Debian Bullseye as base - compatible with Raspberry Pi Zero W (ARMv6)
FROM balenalib/raspberry-pi-debian:bullseye

# Install build tools and development libraries (ARM versions by default)
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-utils \
        automake \
        build-essential \
        cmake \
        curl \
        fakeroot \
        g++ \
        gcc \
        git \
        make \
        pkg-config \
        runit \
        sudo \
        symlinks \
        xz-utils \
        libboost-system-dev \
        libboost-iostreams-dev \
        libboost-filesystem-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set up cross-compilation environment variables
ENV HOST=arm-linux-gnueabihf \
    RPXC_ROOT=/rpxc \
    ARCH=arm \
    QEMU_PATH=/usr/bin/qemu-arm-static \
    QEMU_EXECVE=1

# Create necessary directories
RUN mkdir -p $RPXC_ROOT/bin \
 && mkdir -p /build

# Set up symbolic links for cross-compilation tools
# Since we're running ARM natively in QEMU, we just point to the native tools
RUN ln -s /usr/bin/gcc $RPXC_ROOT/bin/${HOST}-gcc \
 && ln -s /usr/bin/g++ $RPXC_ROOT/bin/${HOST}-g++ \
 && ln -s /usr/bin/ar $RPXC_ROOT/bin/${HOST}-ar \
 && ln -s /usr/bin/as $RPXC_ROOT/bin/${HOST}-as \
 && ln -s /usr/bin/ld $RPXC_ROOT/bin/${HOST}-ld \
 && ln -s /usr/bin/ranlib $RPXC_ROOT/bin/${HOST}-ranlib \
 && ln -s /usr/bin/strip $RPXC_ROOT/bin/${HOST}-strip

ENV CROSS_COMPILE=$RPXC_ROOT/bin/$HOST- \
    PATH=$RPXC_ROOT/bin:$PATH \
    SYSROOT=/

COPY image/ /

WORKDIR /build
ENTRYPOINT [ "/rpxc/entrypoint.sh" ]
