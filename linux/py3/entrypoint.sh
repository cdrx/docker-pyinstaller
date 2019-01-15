#!/bin/bash -i

# Fail on errors.
set -e

#
# In case the user specified a custom URL for PYPI, then use
# that one, instead of the default one.
#
if [[ "$PYPI_URL" != "https://pypi.python.org/" ]] || \
   [[ "$PYPI_INDEX_URL" != "https://pypi.python.org/simple" ]]; then
    # the funky looking regexp just extracts the hostname, excluding port
    # to be used as a trusted-host.
    mkdir -p /root/pip
    echo "[global]" > /root/pip/pip.conf
    echo "index = $PYPI_URL" >> /root/pip/pip.conf
    echo "index-url = $PYPI_INDEX_URL" >> /root/pip/pip.conf
    echo "trusted-host = $(echo $PYPI_URL | perl -pe 's|^.*?://(.*?)(:.*?)?/.*$|$1|')" >> /root/pip/pip.conf

    echo "Using custom pip.conf: "
    cat /root/pip/pip.conf
fi

cd /src

if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi # [ -f requirements.txt ]

echo "$@"

if [[ "$@" == "" ]]; then
    pyinstaller --clean -y --dist ./dist/linux --workpath /tmp *.spec
    chown -R --reference=. ./dist/linux
else
    sh -c "$@"
fi # [[ "$@" == "" ]]

