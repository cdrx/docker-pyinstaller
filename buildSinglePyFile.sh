#!/bin/bash

function usage() {
    echo "Function: Create a one-file bundled executable By Python3."
    echo "Usage: $(basename "$0") [OPTION]... FILE..."
    echo "Options:"
    echo "    -h | -help        Show the help mesage"
    echo "    -e                Only Set Env"
    echo "    -r                Only Run Docker"
    exit 1
}

function workDir() {
    cd "$SOURCEPATH" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        SOURCEPATH=$(dirname $SOURCE)
        cd "$SOURCEPATH" || (
            echo "ERROR: $SOURCEPATH 目录不能访问，请检查该目录是否存在或权限配置正确"
            exit 1
        )
    fi
    echo "DEBUG: 当前所在的工作目录为：$(pwd)"
}

function setEnv() {
    # 部署环境准备
    if [[ ! $(command -v pipreqs) ]]; then
        pip install pipreqs
    fi
    if [[ ! -f requirements.txt ]]; then
        pipreqs ./
    fi

    pyi-makespec --onefile ./*.py

    # 打包报错优化
    grep ^aliyun_python_sdk_core requirements.txt &>/dev/null
    if [[ $? -eq 0 ]]; then
        num=$(grep -nE "^\s*datas=\[" ./*.spec | awk -F: '{print $1}')
        echo "WARN: 请将 XXX.spec 文件中的第 $num 行：【 datas=[], 】修改为："
        echo -e "WARN: \tdatas=[('/root/.pyenv/versions/3.6.8/lib/python3.6/site-packages/aliyunsdkcore/data/','aliyunsdkcore/data/')],"
        echo "WARN: 参考资料：https://blog.csdn.net/Huay_Li/article/details/89439837"
        exit 1
    fi
}

function runDocker() {
    # 生成打包文件
    docker run --rm -v "$(pwd):/src/" zyxa/pyinstaller-centos6 "pyinstaller --clean -y --dist ./dist/CentOS6 --workpath /tmp $args *.spec; chown -R --reference=. ./dist ./__pycache__"
    docker run --rm -v "$(pwd):/src/" zyxa/pyinstaller-centos5 "pyinstaller --clean -y --dist ./dist/CentOS5 --workpath /tmp $args *.spec; chown -R --reference=. ./dist ./__pycache__"
    docker run --rm -v "$(pwd):/src/" cdrx/pyinstaller-linux "pyinstaller --clean -y --dist ./dist/linux --workpath /tmp $args *.spec; chown -R --reference=. ./dist ./__pycache__"

    # 返回原始位置，并显示提示信息
    echo "INFO: CentOS 5 版本编译后的程序在: $SOURCEPATH/dist/CentOS5"
    echo "INFO: CentOS 6 版本编译后的程序在: $SOURCEPATH/dist/CentOS6"
    echo "INFO: 其他更高的 Linux 版本编译后的程序在: $SOURCEPATH/dist/linux"
}

function reDir() {
    cd "$OLDPWD" || exit 1
}

OLDPWD=$(pwd)
envFlag=0
runFlag=0

if [ $# -ge 1 ]; then
    declare SOURCE_LIST=()
    SOURCE_circle=0
    for i in "$@"; do
        case "$i" in
        -h)
            usage
            ;;
        -e)
            envFlag=1
            ;;
        -r)
            runFlag=1
            ;;
        *)
            if [[ -f "$i" || -d "$i" ]]; then
                SOURCE_LIST[SOURCE_circle]="$i"
                SOURCE_circle=$(($SOURCE_circle + 1))
            else
                echo "$i is not an option"
                usage
            fi
            ;;
        esac
    done
else
    # usage
    echo "ERROR: 没有指定工作目录，默认对当前目录进行操作"
    SOURCE_LIST[0]=$(pwd)
    envFlag=1
    runFlag=1
fi

if [[ ${#SOURCE_LIST[@]} -lt 1 ]]; then
    echo "ERROR: 没有指定工作目录或文件，请指定工作目录或文件"
    exit 1
fi
for SOURCE in "${SOURCE_LIST[@]}"; do
    SOURCEPATH="$SOURCE"
    workDir
    if [[ $envFlag -eq 1 ]]; then
        setEnv
    fi
    if [[ $runFlag -eq 1 ]]; then
        runDocker
    fi
done
reDir
