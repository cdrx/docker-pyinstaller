FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

ARG PYINSTALLER_VERSION=3.2

# install python
RUN set -x \
    && apt-get update -qy \
    && apt-get install --no-install-recommends -qfy python python-dev python-pip python-setuptools build-essential libmysqlclient-dev \
    && apt-get clean

# install pyinstaller
RUN pip install pyinstaller==$PYINSTALLER_VERSION

RUN mkdir /src/
VOLUME /src/
WORKDIR /src/

ENTRYPOINT if [ -f requirements.txt ]; then pip install -r requirements.txt; fi && pyinstaller
CMD ["--clean", "-y" ,"--dist" ,"./dist/linux", "--workpath", "/tmp" , "*.spec"]

