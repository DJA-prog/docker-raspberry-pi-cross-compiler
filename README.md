# Raspberry Pi Cross-Compiler in a Docker Container

An easy-to-use all-in-one cross compiler for the Raspberry Pi, modernized with current toolchains and libraries.

**Forked and updated** from [sdt/docker-raspberry-pi-cross-compiler](https://github.com/sdt/docker-raspberry-pi-cross-compiler)

This modernized version uses:
- **ARMv6** compatible base (Raspberry Pi Zero W, Pi 1, and all newer models)
- **Debian Bullseye** (instead of outdated Jessie from 2015)
- **GCC 10.2.1** (instead of old Linaro toolchain)
- **CMake 3.18.4** (instead of 2.8)
- Modern development libraries (Boost 1.74, OpenSSL 1.1.1, etc.)
- **Pre-installed libraries**:
  - **tgbot-cpp** - Telegram Bot API C++ library
  - **WiringPi 3.16** - GPIO library (built from source)
  - **pigpio** - GPIO library with daemon interface
  - **Crow** - C++ microframework for web services
  - **SQLite3** - Embedded database
  - **Boost** (system, iostreams, filesystem)
  - **OpenSSL, libcurl, zlib**
  - **ASIO** - Asynchronous I/O library

Perfect for building modern C++ projects like `tgbot-cpp` that require recent toolchains.

## Contents

* [Features](#features)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Custom Images](#custom-images)
* [Examples](#examples)

## Features

* **ARMv6 compatible** - Works on Raspberry Pi Zero W, Pi 1, and all newer models
* **Modern toolchain** - GCC 10.2.1 with Raspberry Pi optimizations
* **CMake 3.18.4** - Build modern C++ projects that require CMake >= 3.10
* **Current libraries** - Boost 1.74, OpenSSL 1.1.1, libcurl, zlib, SQLite3
* **GPIO Libraries** - WiringPi 3.16 and pigpio (built from source for compatibility)
* **Web Framework** - Crow header-only C++ microframework with ASIO
* **Telegram Bot** - tgbot-cpp library pre-installed and ready to use
* **Debian Bullseye base** - Using official Debian ARM packages
* **QEMU emulation** - Runs ARM binaries on x86 hosts transparently
* **Easy-to-use wrapper** - Simple `rpxc` command to run any build tool

## Installation

This image is not intended to be run manually. Instead, there is a helper script which comes bundled with the image.

To install the helper script, run the image with no arguments, and redirect the output to a file.

```bash
mkdir -p ~/bin
docker run djaprog/raspberry-pi-cross-compiler > ~/bin/rpxc
chmod +x ~/bin/rpxc
```

Optionally, add `~/bin` to your PATH in `~/.bashrc`:
```bash
export PATH="$HOME/bin:$PATH"
```

## Usage

`rpxc [command] [args...]`

Execute the given command-line inside the container.

If the command matches one of the rpxc built-in commands (see below), that will be executed locally, otherwise the command is executed inside the container.

`rpxc -- [command] [args...]`

To force a command to run inside the container (in case of a name clash with a built-in command), use `--` before the command.

### Built-in commands

#### install-debian

`rpxc install-debian [--update] package packages...`

Install native packages into the docker image. Changes are committed back to the djaprog/raspberry-pi-cross-compiler image.

#### install-raspbian

`rpxc install-raspbian [--update] package packages...`

Install raspbian packages from the raspbian repositories into the sysroot of the docker image. Changes are committed back to the djaprog/raspberry-pi-cross-compiler image.

#### update-image

`rpxc update-image`

Pull the latest version of the docker image.

If a new docker image is available, any extra packages installed with `install-debian` or `install-raspbian` _will be lost_.

#### update-script

`rpxc update-script`

Update the installed rpxc script with the one bundled in the image.

#### update

`rpxc update`

Update both the docker image and the rpxc script.

## Configuration

The following command-line options and environment variables are used. In all cases, the command-line option overrides the environment variable.

### RPXC_CONFIG / --config &lt;path-to-config-file&gt;

This file is sourced if it exists.

Default: `~/.rpxc`

### RPXC_IMAGE / --image &lt;docker-image-name&gt;

The docker image to run.

Default: djaprog/raspberry-pi-cross-compiler

### RPXC_ARGS / --args &lt;docker-run-args&gt;

Extra arguments to pass to the `docker run` command.

## Custom Images

Using `rpxc install-debian` and `rpxc install-raspbian` are really only intended for getting a build environment together. Once you've figured out which debian and raspbian packages you need, it's better to create a custom downstream image that has all your tools and development packages built in.

### Create a Dockerfile

```Dockerfile
FROM djaprog/raspberry-pi-cross-compiler

# Install some native build-time tools
RUN install-debian scons

# Install additional raspbian development libraries
RUN install-raspbian libboost-thread-dev
```

### Name your image with an RPXC_IMAGE variable and build the image

```sh
export RPXC_IMAGE=my-custom-rpxc-image
docker build -t $RPXC_IMAGE .
```

### With RPXC_IMAGE set, rpxc will automatically use your new image.

```sh
# These are typical cross-compilation flags to pass to configure.
# Note the use of single quotes in the shell command-line. We want the
# variables to be interpolated in the container, not in the host system.
rpxc sh -c 'CFLAGS=--sysroot=$SYSROOT ./configure --host=$HOST'
rpxc make
```

Another way to achieve this is to create a shell script.

```sh
#!/bin/sh
CFLAGS=--sysroot=$SYSROOT ./configure --host=$HOST
make
```

And call it as `rpxc ./mymake.sh`

## Examples

See the [examples directory](https://github.com/sdt/docker-raspberry-pi-cross-compiler/tree/master/example) for some real examples.

## Pre-installed Libraries

The following libraries are built and installed in the cross-compilation environment:

### GPIO Libraries
- **WiringPi 3.16** - Built from source with ARM cross-compiler
  - Headers: `/usr/arm-linux-gnueabihf/include/wiringPi*.h`
  - Libraries: `/usr/arm-linux-gnueabihf/lib/libwiringPi.so`, `libwiringPiDev.so`
  
- **pigpio** - GPIO library with daemon interface
  - Headers: `/usr/arm-linux-gnueabihf/include/pigpio*.h`
  - Libraries: `/usr/arm-linux-gnueabihf/lib/libpigpio.so`, `libpigpiod_if.so`, `libpigpiod_if2.so`

### Communication & Web
- **tgbot-cpp** - Telegram Bot API C++ library
  - Headers: `/usr/local/include/tgbot/`
  - Libraries: `/usr/local/lib/libTgBot.*`

- **Crow** - C++ microframework for web services
  - Headers: `/usr/local/include/crow/`
  - Header-only library with ASIO dependency

### Database
- **SQLite3** - Embedded SQL database
  - Debian package: `libsqlite3-dev:armhf`

### Core Libraries
- **Boost 1.74** - system, iostreams, filesystem modules (armhf)
- **OpenSSL 1.1.1** - Cryptography and SSL/TLS (armhf)
- **libcurl** - HTTP client library (armhf)
- **zlib** - Compression library (armhf)
- **ASIO** - Asynchronous I/O C++ library

## Building Projects

For CMake-based projects, use the ARM cross-compiler:

```bash
rpxc bash -c "mkdir -p build && cd build && cmake -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ .. && make"
```

The compiler will automatically find libraries in:
- `/usr/arm-linux-gnueabihf/lib` - ARM libraries
- `/usr/local/lib` - Additional libraries
- `/usr/lib` - System libraries
