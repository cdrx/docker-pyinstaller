FROM centos:5.11
SHELL ["/bin/bash", "-i", "-c"]

ARG PYTHON_VERSION=3.6.8
ARG PYINSTALLER_VERSION=3.4
ARG CURL_VERSION=7.49.1
ARG OPENSSL_VERSION=1.0.2s
ARG GIT_VERSION=2.17.0

ENV PYPI_URL=https://pypi.python.org/
ENV PYPI_INDEX_URL=https://pypi.python.org/simple
ENV PYENV_VERSION=${PYTHON_VERSION}

COPY entrypoint.sh /entrypoint.sh
COPY curl-${CURL_VERSION}.tar.gz /curl-${CURL_VERSION}.tar.gz
COPY openssl-${OPENSSL_VERSION}.tar.gz /openssl-${OPENSSL_VERSION}.tar.gz
COPY git-${GIT_VERSION}.tar.gz /git-${GIT_VERSION}.tar.gz

RUN \
    set -x \
    # Setting Yum Repo
    && cp -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak \
    && cp -f /etc/yum.repos.d/libselinux.repo /etc/yum.repos.d/libselinux.repo.bak \
    && sed -i 's/^mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Base.repo \
    && sed -i 's/^mirrorlist/#mirrorlist/g' /etc/yum.repos.d/libselinux.repo \
    && sed -i 's/^#baseurl=http:\/\/mirror.centos.org\/centos\/\$releasever/baseurl=http:\/\/vault.centos.org\/5.11/g' /etc/yum.repos.d/CentOS-Base.repo \
    && sed -i 's/^#baseurl=http:\/\/mirror.centos.org\/centos\/\$releasever/baseurl=http:\/\/vault.centos.org\/5.11/g' /etc/yum.repos.d/libselinux.repo \
    # && sed -i 's/^#baseurl=http:\/\/mirror.centos.org\/centos\/\$releasever/baseurl=http:\/\/archive.kernel.org\/centos-vault\/5.11/g' /etc/yum.repos.d/CentOS-Base.repo \
    # && sed -i 's/^#baseurl=http:\/\/mirror.centos.org\/centos\/\$releasever/baseurl=http:\/\/archive.kernel.org\/centos-vault\/5.11/g' /etc/yum.repos.d/libselinux.repo \
    # install requirements
    && while true; do \
    yum install -y gcc gcc44 zlib-devel python-setuptools readline-devel wget make perl curl \
    openssl openssl-devel \
    zlib-devel \
    sqlite-devel \
    readline-devel \
    bzip2-devel bzip2-libs \
    && break; done \
    # update openssl
    # && while true; do \
    # wget --no-check-certificate https://www.openssl.org/source/openssl-1.0.2s.tar.gz \
    # && break; done \
    && cd / \
    && tar zxvf openssl-* \
    && cd openssl-* \
    && ./config -fpic shared && make && make install \
    && mv -f /usr/bin/openssl /usr/bin/openssl.old \
    && ln -s ../local/ssl/bin/openssl  /usr/bin/openssl \
    && ln -s ../local/ssl/include/openssl  /usr/include/openssl \
    && echo "/usr/local/ssl/lib" >> /etc/ld.so.conf \
    && ldconfig \
    && cd / \
    && rm -rf openssl-* \
    # update to curl 7.49
    && tar -xzvf curl-*.tar.gz \
    && cd curl-* \
    && ./configure --with-ssl=/usr/local/ssl --disable-ldap && make && make install \
    && mv -f /usr/bin/curl /usr/bin/curl.old \
    && ln -s ../local/bin/curl /usr/bin/curl \
    && cd / \
    && rm -rf curl-* \
    # update to git 2.17.0
    && while true; do \
    yum install -y epel-release \
    && yum install -y \
    autoconf expat-devel gettext-devel\
    && break; done \
    # && wget --no-check-certificate https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.17.0.tar.gz \
    && tar zxvf git-* \
    && cd git-* \
    && autoconf && ./configure --with-ssl=/usr/local/ssl --with-curl=/usr/local && make all && make install \
    # && mv -f /usr/bin/git /usr/bin/git.old \
    # && mv -f /usr/bin/git-receive-pack /usr/bin/git-receive-pack.old \
    # && mv -f /usr/bin/git-shell /usr/bin/git-shell.old \
    # && mv -f /usr/bin/git-upload-archive /usr/bin/git-upload-archive.old \
    # && mv -f /usr/bin/git-upload-pack /usr/bin/git-upload-pack.old \
    && ln -s ../local/bin/git* /usr/bin/ \
    && cd / \
    && rm -rf git-* \
    # install pyenv
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \
    && source ~/.bashrc \
    && curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | USE_GIT_URI=n bash \
    && echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
    && source ~/.bashrc \
    # install python
    # && PYTHON_CONFIGURE_OPTS="--enable-shared" CFLAGS="-I$(brew --prefix openssl)/include" LDFLAGS="-L$(brew --prefix openssl)/lib" pyenv install $PYTHON_VERSION \
    && PYTHON_CONFIGURE_OPTS="--enable-shared" CFLAGS="-I/usr/local/ssl/include" LDFLAGS="-L/usr/local/ssl/lib" pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pip install --upgrade pip \
    # install pyinstaller
    && pip install pyinstaller==$PYINSTALLER_VERSION \
    && mkdir /src/ \
    && chmod +x /entrypoint.sh \
    # clean Env
    && yum clean all

VOLUME /src/
WORKDIR /src/

ENTRYPOINT ["/entrypoint.sh"]
