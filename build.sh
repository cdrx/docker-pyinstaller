#!/bin/sh

# Run NAMESPACE=custom ./build.sh to customize images namespace
NAMESPACE=${NAMESPACE-cdrx}

echo "Building Default Linux image (Python 3, Precise, 64bit)"
docker build -f Dockerfile-py3-precise-amd64 \
-t $NAMESPACE/pyinstaller-linux \
-t $NAMESPACE/pyinstaller-linux:64bit \
-t $NAMESPACE/pyinstaller-linux:python3 \
-t $NAMESPACE/pyinstaller-linux:precise \
-t $NAMESPACE/pyinstaller-linux:python3-64bit \
-t $NAMESPACE/pyinstaller-linux:python3-precise \
-t $NAMESPACE/pyinstaller-linux:python3-precise-64bit \
.

echo "Building Default Windows image (Python 3, Xenial, 64bit)"
docker build -f Dockerfile-py3-xenial-win64 \
-t $NAMESPACE/pyinstaller-windows \
-t $NAMESPACE/pyinstaller-windows:64bit \
-t $NAMESPACE/pyinstaller-windows:xenial \
-t $NAMESPACE/pyinstaller-windows:python3 \
-t $NAMESPACE/pyinstaller-windows:python3-64bit \
-t $NAMESPACE/pyinstaller-windows:python3-xenial \
-t $NAMESPACE/pyinstaller-windows:python3-xenial-64bit \
.

echo "Building Default Linux 32 bits image (Python 3, Precise, 32bit)"
docker build -f Dockerfile-py3-precise-i386 \
-t $NAMESPACE/pyinstaller-linux:32bit \
-t $NAMESPACE/pyinstaller-linux:python3-32bit \
-t $NAMESPACE/pyinstaller-linux:python3-precise-32bit \
.

echo "Building Default Windows 32 bits image (Python 3, Xenial, 32bit)"
docker build -f Dockerfile-py3-xenial-win32 \
-t $NAMESPACE/pyinstaller-windows:32bit \
-t $NAMESPACE/pyinstaller-windows:python3-32bit \
-t $NAMESPACE/pyinstaller-windows:python3-xenial-32bit \
.

echo "Building Default Windows Python 2 image (Python 2, Trusty, 32bit)"
docker build -f Dockerfile-py2-trusty-win32 \
-t $NAMESPACE/pyinstaller-linux:python2 \
-t $NAMESPACE/pyinstaller-linux:python2-trusty \
-t $NAMESPACE/pyinstaller-linux:python2-32bit \
-t $NAMESPACE/pyinstaller-linux:python2-trusty-32bit \
.

echo "Building Default Linux Python 2 image (Python 2, Precise, 64bit)"
docker build -f Dockerfile-py2-precise-amd64 \
-t $NAMESPACE/pyinstaller-linux:python2 \
-t $NAMESPACE/pyinstaller-linux:python2-precise \
-t $NAMESPACE/pyinstaller-linux:python2-precise-64bit \
.

echo "Building Default Linux Focal image (Python 3, Focal, 64bit)"
docker build -f Dockerfile-py3-focal-amd64 \
-t $NAMESPACE/pyinstaller-linux:focal \
-t $NAMESPACE/pyinstaller-linux:python3-focal \
-t $NAMESPACE/pyinstaller-linux:python3-focal-64bit \
.

echo "Building Default Linux Xenial image (Python 3, Xenial, 64bit)"
docker build -f Dockerfile-py3-xenial-amd64 \
-t $NAMESPACE/pyinstaller-linux:xenial \
-t $NAMESPACE/pyinstaller-linux:python3-xenial \
-t $NAMESPACE/pyinstaller-linux:python3-xenial-64bit \
.
