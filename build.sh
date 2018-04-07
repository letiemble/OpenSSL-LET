#!/bin/bash

###############################################################################
##                                                                           ##
## Build and package OpenSSL static libraries for OSX/iOS                    ##
##                                                                           ##
## This script is in the public domain.                                      ##
##                                                                           ##
## Creator     : Laurent Etiemble                                            ##
##                                                                           ##
###############################################################################

## --------------------
## Parameters
## --------------------

VERSION=1.0.2n

# These values are used to avoid version detection
FAKE_NIBBLE=0x102031af
FAKE_TEXT="OpenSSL 0.9.8y 5 Feb 2013"

## --------------------
## Variables
## --------------------

DEVELOPER_DIR=`xcode-select -print-path`

BASE_DIR=`pwd`
WORK_DIR="$BASE_DIR/work"
BUILD_DIR="$WORK_DIR/build"
FILES_DIR="$WORK_DIR/files"
LOG_DIR="$WORK_DIR"

OPENSSL_NAME="openssl-$VERSION"
OPENSSL_FILE="$OPENSSL_NAME.tar.gz"
OPENSSL_URL="https://www.openssl.org/source/$OPENSSL_FILE"
OPENSSL_PATH="$FILES_DIR/$OPENSSL_FILE"

## --------------------
## Main
## --------------------

_unarchive() {
	# Expand source tree if needed
	if [ ! -d "$SRC_DIR" ]; then
		echo "Unarchive sources for $PLATFORM-$ARCH..."
		(cd "$BUILD_DIR"; tar -zxf "$OPENSSL_PATH"; mv "$OPENSSL_NAME" "$SRC_DIR";)
	fi
}

_configure() {
	# Configure
	if [ "x$DONT_CONFIGURE" == "x" ]; then
		echo "Configuring $PLATFORM-$ARCH..."
		(cd "$SRC_DIR"; CROSS_TOP="$CROSS_TOP" CROSS_SDK="$CROSS_SDK" CC="$CC" ./Configure --prefix="$DST_DIR" -no-apps "$COMPILER" > "$LOG_FILE" 2>&1)
	fi
}

_build() {
	# Build
	if [ "x$DONT_BUILD" == "x" ]; then
		echo "Building $PLATFORM-$ARCH..."
		(cd "$SRC_DIR"; CROSS_TOP="$CROSS_TOP" CROSS_SDK="$CROSS_SDK" CC="$CC" make >> "$LOG_FILE" 2>&1)
	fi
}

_package() {
	INCLUDE_DIR="$BASE_DIR/include/$1"
	LIB_DIR="$BASE_DIR/lib/$1"
	ARCHIVE_DIR="$WORK_DIR/archive"
	ARCHIVE="$BASE_DIR/openssl-$VERSION-$2.tar.gz"

	rm -Rf "$ARCHIVE_DIR"
	mkdir -p "$ARCHIVE_DIR"

	cp -LR "$INCLUDE_DIR" "$ARCHIVE_DIR/include"
	cp -LR "$LIB_DIR" "$ARCHIVE_DIR/lib"

	(cd $ARCHIVE_DIR; tar -zcf "$ARCHIVE" .; cd -)
}

build_osx() {
	ARCHS="i386 x86_64"
	for ARCH in $ARCHS; do
		PLATFORM="macosx"
		COMPILER="darwin-i386-cc"
		SRC_DIR="$BUILD_DIR/$PLATFORM-$ARCH"
		LOG_FILE="$LOG_DIR/$PLATFORM-$ARCH.log"

		# Select the compiler
		if [ "$ARCH" == "i386" ]; then
			COMPILER="darwin-i386-cc"
            MIN_OSX=10.6
		else
			COMPILER="darwin64-x86_64-cc"
            MIN_OSX=10.6
		fi

        OSX_SDK=`xcrun --sdk $PLATFORM --show-sdk-version`
        CROSS_TOP=`xcrun --sdk $PLATFORM --show-sdk-platform-path`"/Developer"
        CROSS_SDK=`xcrun --sdk $PLATFORM --show-sdk-path | xargs basename`
		CC="$DEVELOPER_DIR/usr/bin/gcc -arch $ARCH"

		_unarchive
		_configure

		# Patch Makefile
		sed -ie "s/^CFLAG= -/CFLAG=  -mmacosx-version-min=$MIN_OSX -/" "$SRC_DIR/Makefile"

		# Patch versions
		sed -ie "s/^# define OPENSSL_VERSION_NUMBER.*$/# define OPENSSL_VERSION_NUMBER  $FAKE_NIBBLE/" "$SRC_DIR/crypto/opensslv.h"
		sed -ie "s/^#  define OPENSSL_VERSION_TEXT.*$/#  define OPENSSL_VERSION_TEXT  \"$FAKE_TEXT\"/" "$SRC_DIR/crypto/opensslv.h"

		_build
	done
}

build_ios() {
	ARCHS="i386 x86_64 armv7 armv7s arm64"
	for ARCH in $ARCHS; do
		PLATFORM="iphoneos"
		COMPILER="iphoneos-cross"
		SRC_DIR="$BUILD_DIR/$PLATFORM-$ARCH"
		LOG_FILE="$LOG_DIR/$PLATFORM-$ARCH.log"

		# Select the compiler
		if [ "$ARCH" == "i386" ]; then
			PLATFORM="iphonesimulator"
			MIN_IOS="6.0"
		elif [ "$ARCH" == "x86_64" ]; then
			PLATFORM="iphonesimulator"
			MIN_IOS="7.0"
		elif [ "$ARCH" == "arm64" ]; then
			MIN_IOS="7.0"
		else
			MIN_IOS="6.0"
		fi

        IOS_SDK=`xcrun --sdk $PLATFORM --show-sdk-version`
        CROSS_TOP=`xcrun --sdk $PLATFORM --show-sdk-platform-path`"/Developer"
		CROSS_SDK=`xcrun --sdk $PLATFORM --show-sdk-path | xargs basename`
		CC="clang -arch $ARCH -fembed-bitcode"

		_unarchive
		_configure

		# Patch Makefile
		if [ "$ARCH" == "x86_64" ]; then
			sed -ie "s/^CFLAG= -/CFLAG=  -miphoneos-version-min=$MIN_IOS -DOPENSSL_NO_ASM -/" "$SRC_DIR/Makefile"
    	else
			sed -ie "s/^CFLAG= -/CFLAG=  -miphoneos-version-min=$MIN_IOS -/" "$SRC_DIR/Makefile"
        fi

		# Patch versions
		sed -ie "s/^# define OPENSSL_VERSION_NUMBER.*$/# define OPENSSL_VERSION_NUMBER  $FAKE_NIBBLE/" "$SRC_DIR/crypto/opensslv.h"
		sed -ie "s/^#  define OPENSSL_VERSION_TEXT.*$/#  define OPENSSL_VERSION_TEXT  \"$FAKE_TEXT\"/" "$SRC_DIR/crypto/opensslv.h"

		_build
	done
}

distribute_osx() {
	FILES="libcrypto.a libssl.a"
	INCLUDE_DIR="$BASE_DIR/include/osx"
	LIB_DIR="$BASE_DIR/lib/osx"
	mkdir -p "$INCLUDE_DIR"
	mkdir -p "$LIB_DIR"

	cp -LR "$BUILD_DIR/macosx-i386/include/" "$INCLUDE_DIR"

	# Alter rsa.h to make Swift happy
	sed -i .bak 's/const BIGNUM \*I/const BIGNUM *i/g' "$INCLUDE_DIR/openssl/rsa.h"

	for f in $FILES; do
		lipo -create \
			"$BUILD_DIR/macosx-i386/$f" \
			"$BUILD_DIR/macosx-x86_64/$f" \
			-output "$LIB_DIR/$f"
	done
}

distribute_ios() {
	FILES="libcrypto.a libssl.a"
	INCLUDE_DIR="$BASE_DIR/include/ios"
	LIB_DIR="$BASE_DIR/lib/ios"
	mkdir -p "$INCLUDE_DIR"
	mkdir -p "$LIB_DIR"

	cp -LR "$BUILD_DIR/iphoneos-i386/include/" "$INCLUDE_DIR"

	# Alter rsa.h to make Swift happy
	sed -i .bak 's/const BIGNUM \*I/const BIGNUM *i/g' "$INCLUDE_DIR/openssl/rsa.h"

	for f in $FILES; do
		lipo -create \
			"$BUILD_DIR/iphoneos-i386/$f" \
			"$BUILD_DIR/iphoneos-x86_64/$f" \
			"$BUILD_DIR/iphoneos-arm64/$f" \
			"$BUILD_DIR/iphoneos-armv7/$f" \
			"$BUILD_DIR/iphoneos-armv7s/$f" \
			-output "$LIB_DIR/$f"
	done
}

package() {
	_package "ios" "iOS"
	_package "osx" "MacOSX"
}

prepare() {
    # Create folders
    mkdir -p "$BUILD_DIR"
    mkdir -p "$FILES_DIR"
}

download() {
    # Retrieve OpenSSL tarbal if needed
    if [ ! -e "$OPENSSL_PATH" ]; then
    	curl "$OPENSSL_URL" -o "$OPENSSL_PATH"
    fi
}

prepare
download

build_osx
build_ios

distribute_osx
distribute_ios

package
