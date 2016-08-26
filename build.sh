#!/bin/bash
set -x

docker build -t cdrx/pyinstaller-windows:python2 -f ./windows/py2/Dockerfile ./windows/py2
#docker build -t cdrx/pyinstaller-windows:python3 -f ./windows/py3/Dockerfile ./windows/py3

docker build -t cdrx/pyinstaller-linux:python2 -f ./linux/py2/Dockerfile ./linux/py2
docker build -t cdrx/pyinstaller-linux:python3 -f ./linux/py3/Dockerfile ./linux/py3

docker push cdrx/pyinstaller-windows
docker push cdrx/pyinstaller-linux

docker tag cdrx/pyinstaller-linux:python3 cdrx/pyinstaller-linux:latest
docker push cdrx/pyinstaller-linux:latest

docker tag cdrx/pyinstaller-windows:python2 cdrx/pyinstaller-windows:latest
docker push cdrx/pyinstaller-windows:latest
