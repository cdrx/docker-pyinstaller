#!/bin/bash

function usage() {
    echo "Function: Put files or directories in trashcan."
    echo "Usage: trash [OPTION]... FILE..."
    echo "Options:"
    echo "    -h | -help        Show the help mesage"
    echo "    -t | -trash       Move contents to trashcan"
}

if [[ $1 == '' ]]; then
    echo "没有指定工作目录，默认对当前目录进行操作"
    SOURCE=$(pwd)
else
    SOURCE=$1
fi

OLDPWD=$(pwd)
SOURCEPATH=$SOURCE
cd $SOURCE 2>/dev/null
if [[ $? != 0 ]]; then
    SOURCEPATH=$(dirname $SOURCE)
    cd $SOURCEPATH
fi

function setEnv() {
    # 部署环境准备
    if [[ ! $(command -v pipreqs) ]]; then
        pip install pipreqs
    fi
    rm -f requirements.txt
    pipreqs ./

    pyi-makespec --onefile ./*.py

    # 打包报错优化
    grep ^aliyun_python_sdk_core requirements.txt &>/dev/null
    if [[ $? -eq 0 ]]; then
        num=$(grep -nE "^\s*datas=\[" ./*.spec | awk -F: '{print $1}')
        echo "请将 XXX.spec 文件中的第 $num 行：【 datas=[], 】修改为："
        echo -e "\tdatas=[('/root/.pyenv/versions/3.6.8/lib/python3.6/site-packages/aliyunsdkcore/data/','aliyunsdkcore/data/')],"
        echo "参考资料：https://blog.csdn.net/Huay_Li/article/details/89439837"
        exit 1
    fi
}

function runDocker() {
    # 生成打包文件
    docker run --rm -v "$(pwd):/src/" zyxa/pyinstaller-centos6 "pyinstaller --clean -y --dist ./dist/CentOS6 --workpath /tmp $args *.spec; chown -R --reference=. ./dist ./__pycache__"
    docker run --rm -v "$(pwd):/src/" zyxa/pyinstaller-centos5 "pyinstaller --clean -y --dist ./dist/CentOS5 --workpath /tmp $args *.spec; chown -R --reference=. ./dist ./__pycache__"
    docker run --rm -v "$(pwd):/src/" cdrx/pyinstaller-linux "pyinstaller --clean -y --dist ./dist/linux --workpath /tmp $args *.spec; chown -R --reference=. ./dist ./__pycache__"

    # 返回原始位置，并显示提示信息
    cd "$OLDPWD" || exit 1
    echo "CentOS 5 版本编译后的程序在: $SOURCEPATH/dist/CentOS5"
    echo "CentOS 6 版本编译后的程序在: $SOURCEPATH/dist/CentOS6"
    echo "其他更高的 Linux 版本编译后的程序在: $SOURCEPATH/dist/linux"
}

if [ $# -ge 1 ]; then
    declare param=()
    param_circle=0
    for i in "$@"; do
        param[param_circle]=$i
        param_circle=$(($param_circle + 1))
    done
    unset param[0]
    case "$1" in
    -h)
        usage
        ;;
    -e)
        setEnv
        ;;
    -r)
        runDocker
        ;;
    *)
        echo "$1 is not an option"
        usage
        ;;
    esac
else
    usage
fi
