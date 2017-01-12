FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

ARG WINE_VERSION=winehq-devel
ARG PYTHON_VERSION=3.5.2
ARG PYINSTALLER_VERSION=3.2

# we need wine for this all to work, so we'll use the PPA
RUN set -x \
    && dpkg --add-architecture i386 \
    && apt-get update -qy \
    && apt-get install --no-install-recommends -qfy software-properties-common \
    && add-apt-repository ppa:wine/wine-builds \
    && apt-get update -qy \
    && apt-get install --no-install-recommends -qfy $WINE_VERSION winetricks wget \
    && apt-get clean

# wine settings
ENV WINEARCH win32
ENV WINEDEBUG fixme-all
ENV WINEPREFIX /wine

# PYPI repository location
ARG pypi_url=https://pypi.python.org/
# PYPI index location
ARG pypi_index_url=https://pypi.python.org/simple

# the funky looking regexp just extracts the hostname, excluding port
# to be used as a trusted-host.
RUN mkdir -p /wine/drive_c/users/root/pip && \
    echo "[global]" > /wine/drive_c/users/root/pip/pip.ini && \
    echo "index = $pypi_url" >> /wine/drive_c/users/root/pip/pip.ini && \
    echo "index-url = $pypi_index_url" >> /wine/drive_c/users/root/pip/pip.ini && \
    echo "trusted-host = $(echo $pypi_url | perl -pe 's|^.*?://(.*?)(:.*?)?/.*$|$1|')" >> /wine/drive_c/users/root/pip/pip.ini

# install python in wine, using the msi packages to install, extracting
# the files directly, since installing isn't running correctly.
RUN set -x \
    && winetricks win7 \
    && for msifile in `echo core dev exe lib pip tcltk tools`; do \
        wget -nv "https://www.python.org/ftp/python/$PYTHON_VERSION/win32/${msifile}.msi"; \
        wine msiexec /a "${msifile}.msi" /qb TARGETDIR=C:/Python35; \
        rm ${msifile}.msi; \
    done \
    && cd /wine/drive_c/Python35 \
    && echo 'wine '\''C:\Python35\python.exe'\'' "$@"' > /usr/bin/python \
    && echo 'wine '\''C:\Python35\Scripts\easy_install.exe'\'' "$@"' > /usr/bin/easy_install \
    && echo 'wine '\''C:\Python35\Scripts\pip.exe'\'' "$@"' > /usr/bin/pip \
    && echo 'wine '\''C:\Python35\Scripts\pyinstaller.exe'\'' "$@"' > /usr/bin/pyinstaller \
    && (pip install -U pip || true) \
    && echo 'assoc .py=PythonScript' | wine cmd \
    && echo 'ftype PythonScript=c:\Python35\python.exe "%1" %*' | wine cmd \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
    && chmod +x /usr/bin/python /usr/bin/easy_install /usr/bin/pip /usr/bin/pyinstaller \
    && rm -rf /tmp/.wine-*

# install pyinstaller
RUN /usr/bin/pip install pyinstaller==$PYINSTALLER_VERSION

# put the src folder inside wine
RUN mkdir /src/ && ln -s /src /wine/drive_c/src
VOLUME /src/
WORKDIR /wine/drive_c/src/
RUN mkdir -p /wine/drive_c/tmp

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

