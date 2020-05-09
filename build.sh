#!/bin/sh

echo "Building Default Linux image (Python 3, Precise, 64bit)"
docker build -f Dockerfile-py3-precise-amd64 \
-t cdrx/pyinstaller-linux \
-t cdrx/pyinstaller-linux:64bit \
-t cdrx/pyinstaller-linux:python3 \
-t cdrx/pyinstaller-linux:precise \
-t cdrx/pyinstaller-linux:python3-64bit \
-t cdrx/pyinstaller-linux:python3-precise \
-t cdrx/pyinstaller-linux:python3-precise-64bit \
.

echo "Building Default Windows image (Python 3, Xenial, 64bit)"
docker build -f Dockerfile-py3-xenial-win64 \
-t cdrx/pyinstaller-windows \
-t cdrx/pyinstaller-windows:64bit \
-t cdrx/pyinstaller-windows:xenial \
-t cdrx/pyinstaller-windows:python3 \
-t cdrx/pyinstaller-windows:python3-64bit \
-t cdrx/pyinstaller-windows:python3-xenial \
-t cdrx/pyinstaller-windows:python3-xenial-64bit \
.

echo "Building Default Linux 32 bits image (Python 3, Precise, 32bit)"
docker build -f Dockerfile-py3-precise-i386 \
-t cdrx/pyinstaller-linux:32bit \
-t cdrx/pyinstaller-linux:python3-32bit \
-t cdrx/pyinstaller-linux:python3-precise-32bit \
.

echo "Building Default Windows 32 bits image (Python 3, Xenial, 32bit)"
docker build -f Dockerfile-py3-xenial-win32 \
-t cdrx/pyinstaller-windows:32bit \
-t cdrx/pyinstaller-windows:python3-32bit \
-t cdrx/pyinstaller-windows:python3-xenial-32bit \
.

echo "Building Default Windows Python 2 image (Python 2, Trusty, 32bit)"
docker build -f Dockerfile-py2-trusty-win32 \
-t cdrx/pyinstaller-linux:python2 \
-t cdrx/pyinstaller-linux:python2-trusty \
-t cdrx/pyinstaller-linux:python2-32bit \
-t cdrx/pyinstaller-linux:python2-trusty-32bit \
.

echo "Building Default Linux Python 2 image (Python 2, Precise, 64bit)"
docker build -f Dockerfile-py2-precise-amd64 \
-t cdrx/pyinstaller-linux:python2 \
-t cdrx/pyinstaller-linux:python2-precise \
-t cdrx/pyinstaller-linux:python2-precise-64bit \
.

echo "Building Default Linux Focal image (Python 3, Focal, 64bit)"
docker build -f Dockerfile-py3-focal-amd64 \
-t cdrx/pyinstaller-linux:focal \
-t cdrx/pyinstaller-linux:python3-focal \
-t cdrx/pyinstaller-linux:python3-focal-64bit \
.

echo "Building Default Linux Xenial image (Python 3, Xenial, 64bit)"
docker build -f Dockerfile-py3-xenial-amd64 \
-t cdrx/pyinstaller-linux:xenial \
-t cdrx/pyinstaller-linux:python3-xenial \
-t cdrx/pyinstaller-linux:python3-xenial-64bit \
.
