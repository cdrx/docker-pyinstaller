#!/bin/bash

cd /src

if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi # [ -f requirements.txt ]

echo "$@"

if [[ "$@" == "" ]]; then
    pyinstaller --clean -y --dist ./dist/windows --workpath /tmp *.spec
else
    $@
fi # [[ "$@" == "" ]]
