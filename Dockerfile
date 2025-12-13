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
        libsqlite3-dev:armhf \
        # Crow dependencies
        libasio-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Build WiringPi from source with cross-compiler to match glibc
RUN git clone --depth 1 --branch 3.16 https://github.com/WiringPi/WiringPi.git /tmp/WiringPi \
 && cd /tmp/WiringPi/wiringPi \
 && make CC=arm-linux-gnueabihf-gcc AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib \
 && mkdir -p /usr/arm-linux-gnueabihf/include /usr/arm-linux-gnueabihf/lib \
 && cp *.h /usr/arm-linux-gnueabihf/include/ \
 && cp libwiringPi.so.* /usr/arm-linux-gnueabihf/lib/ \
 && cd /usr/arm-linux-gnueabihf/lib \
 && ln -sf libwiringPi.so.* libwiringPi.so \
 && cd /tmp/WiringPi/devLib \
 && make CC=arm-linux-gnueabihf-gcc AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib \
 && cp *.h /usr/arm-linux-gnueabihf/include/ \
 && cp libwiringPiDev.so.* /usr/arm-linux-gnueabihf/lib/ \
 && cd /usr/arm-linux-gnueabihf/lib \
 && ln -sf libwiringPiDev.so.* libwiringPiDev.so \
 && mkdir -p /usr/lib /usr/local/lib /opt/vc/lib \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libwiringPi.so /usr/lib/libwiringPi.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libwiringPiDev.so /usr/lib/libwiringPiDev.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libwiringPi.so /usr/local/lib/libwiringPi.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libwiringPiDev.so /usr/local/lib/libwiringPiDev.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libwiringPi.so /opt/vc/lib/libwiringPi.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libwiringPiDev.so /opt/vc/lib/libwiringPiDev.so \
 && rm -rf /tmp/WiringPi

# Build and install pigpio library
RUN git clone https://github.com/joan2937/pigpio.git /tmp/pigpio \
 && cd /tmp/pigpio \
 && make CC=arm-linux-gnueabihf-gcc AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib STRIP=arm-linux-gnueabihf-strip lib \
 && mkdir -p /usr/arm-linux-gnueabihf/include /usr/arm-linux-gnueabihf/lib \
 && cp pigpio.h pigpiod_if.h pigpiod_if2.h /usr/arm-linux-gnueabihf/include/ \
 && cp libpigpio.so.1 libpigpiod_if.so.1 libpigpiod_if2.so.1 /usr/arm-linux-gnueabihf/lib/ \
 && cd /usr/arm-linux-gnueabihf/lib \
 && ln -sf libpigpio.so.1 libpigpio.so \
 && ln -sf libpigpiod_if.so.1 libpigpiod_if.so \
 && ln -sf libpigpiod_if2.so.1 libpigpiod_if2.so \
 && mkdir -p /usr/lib /usr/local/lib \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libpigpio.so /usr/lib/libpigpio.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libpigpiod_if.so /usr/lib/libpigpiod_if.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libpigpiod_if2.so /usr/lib/libpigpiod_if2.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libpigpio.so /usr/local/lib/libpigpio.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libpigpiod_if.so /usr/local/lib/libpigpiod_if.so \
 && ln -sf /usr/arm-linux-gnueabihf/lib/libpigpiod_if2.so /usr/local/lib/libpigpiod_if2.so \
 && rm -rf /tmp/pigpio

# Install Crow header-only library (modular version for CMake compatibility)
RUN git clone --depth 1 --branch v1.0+5 https://github.com/CrowCpp/Crow.git /tmp/crow \
 && mkdir -p /usr/local/include/crow \
 && cp -r /tmp/crow/include/crow/* /usr/local/include/crow/ \
 && rm -rf /tmp/crow

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
COPY tgbot-cpp/ /

# Link tgbot-cpp to ARM sysroot for cross-compilation
RUN ln -sf /usr/local/include/tgbot /usr/arm-linux-gnueabihf/include/tgbot \
 && ln -sf /usr/local/lib/libTgBot.* /usr/arm-linux-gnueabihf/lib/ 2>/dev/null || true

WORKDIR /build
ENTRYPOINT [ "/rpxc/entrypoint.sh" ]
