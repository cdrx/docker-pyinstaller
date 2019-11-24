FROM ubuntu:12.04
SHELL ["/bin/bash", "-i", "-c"]

ARG PYTHON_VERSION=3.7.5
ARG PYINSTALLER_VERSION=3.5

ENV PYPI_URL=https://pypi.python.org/
ENV PYPI_INDEX_URL=https://pypi.python.org/simple
ENV PYENV_VERSION=${PYTHON_VERSION}

COPY entrypoint.sh /entrypoint.sh

RUN \
    set -x \
    # update system
    && apt-get update \
    # install requirements
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        zlib1g-dev \
    # install pyenv
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \
    && source ~/.bashrc \
    && curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
    && source ~/.bashrc \
    # install python
    && PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pip install --upgrade pip \
    # install pyinstaller
    && pip install pyinstaller==$PYINSTALLER_VERSION \
    && mkdir /src/ \
    && chmod +x /entrypoint.sh

VOLUME /src/
WORKDIR /src/

ENTRYPOINT ["/entrypoint.sh"]
