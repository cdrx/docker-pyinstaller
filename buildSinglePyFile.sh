#!/bin/bash

function usage() {
    echo "Function: Create a one-file bundled executable By Python3."
    echo "Usage: $(basename "$0") [OPTION]... FILE..."
    echo "Options:"
    echo "    -h | -help        Show the help mesage"
    echo "    -e                Only Set Env"
    echo "    -r                Only Run Docker"
    forceExit
}

function workDir() {
    if ! cd "$SOURCEPATH" 2>/dev/null; then
        SOURCEPATH=$(dirname "$SOURCE")
        cd "$SOURCEPATH" || (
            echo "ERROR: $SOURCEPATH 目录不能访问，请检查该目录是否存在或权限配置正确"
            forceExit
        )
    fi
}

function setEnv() {
    # 部署环境准备
    if ! command -v pipreqs; then
        pip install pipreqs
    fi
    if [[ ! -f requirements.txt ]]; then
        pipreqs ./
    fi

    pyi-makespec --onefile "$param" ./*.py

    # 打包报错优化
    if grep ^aliyun_python_sdk_core requirements.txt &>/dev/null; then
        num=$(grep -nE "^\s*datas=\[" ./*.spec | awk -F: '{print $1}')
        echo "WARN: 请将 XXX.spec 文件中的第 $num 行：【 datas=[], 】修改为："
        echo -e "WARN: \tdatas=[('/root/.pyenv/versions/3.6.8/lib/python3.6/site-packages/aliyunsdkcore/data/','aliyunsdkcore/data/')],"
        echo "WARN: 参考资料：https://blog.csdn.net/Huay_Li/article/details/89439837"
        forceExit
    fi
}

function runDocker() {
    # 生成打包文件
    docker run --rm -v "$(pwd):/src/" zyxa/pyinstaller-centos6 "pyinstaller --clean -y --dist ./dist/CentOS6 --workpath /tmp $param *.spec; chown -R --reference=. ./dist ./__pycache__" | tee "$log2" &
    docker run --rm -v "$(pwd):/src/" zyxa/pyinstaller-centos5 "pyinstaller --clean -y --dist ./dist/CentOS5 --workpath /tmp $param *.spec; chown -R --reference=. ./dist ./__pycache__" | tee "$log1" &
    docker run --rm -v "$(pwd):/src/" cdrx/pyinstaller-linux "pyinstaller --clean -y --dist ./dist/linux --workpath /tmp $param *.spec; chown -R --reference=. ./dist ./__pycache__" | tee "$log3" &
    wait

    # 返回原始位置，并显示提示信息
    echo "INFO: ${projectName} 项目的 CentOS 5 版本编译后的程序在: $SOURCEPATH/dist/CentOS5" | tee "$log1"
    echo "INFO: ${projectName} 项目的 CentOS 6 版本编译后的程序在: $SOURCEPATH/dist/CentOS6" | tee "$log2"
    echo "INFO: ${projectName} 项目的 其他更高的 Linux 版本编译后的程序在: $SOURCEPATH/dist/linux" | tee "$log3"
}

function reDir() {
    cd "$OLDPWD" || forceExit
}

function forceExit() {
    rm -f "$tmpf"
    exit 1
}

function commandCheck() {
    if ! command -v bc; then
        echo "ERROR: 请安装 bc 服务。安装参考命令："
        echo -e "ERROR: CentOS/RedHat:\tsudo yum install -y bc"
        echo -e "ERROR: Ubuntu/Debian:\tsudo apt-get install -y bc"
        forceExit
    fi
    if ! systemctl status docker.service &>/dev/null; then
        echo "ERROR: 请启动 docker 服务，或安装 docker 服务。启动参考命令："
        echo -e "ERROR: \tsudo systemctl start docker.service"
        forceExit
    fi
}

commandCheck
OLDPWD=$(pwd)
envFlag=0
runFlag=0

# Thread control
cpuNum=$(grep -c processor /proc/cpuinfo)
threadNum=$(echo "($cpuNum - 1) / 3 * 3" | bc)
if [[ threadNum -eq 0 ]]; then
    threadNum=1
fi

tmpf=/dev/shm/tmp.fifo
mkfifo $tmpf
exec 9<>$tmpf
for ((i = 0; i < threadNum; i++)); do
    echo -ne "\n" 1>&9
done

if [ $# -ge 1 ]; then
    declare SOURCE_LIST=()
    SOURCE_circle=0
    SOURCE=("$@")
    for ((i = 0; i < ${#SOURCE[@]}; i++)); do
        case "${SOURCE[i]}" in
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
            if [[ -f "${SOURCE[i]}" || -d "${SOURCE[i]}" ]]; then
                SOURCE_LIST[SOURCE_circle]="${SOURCE[i]}"
                SOURCE_circle=$((SOURCE_circle + 1))
            elif pyinstaller --help | grep -w "^\s*${SOURCE[i]}" &>/dev/null; then
                # 判断若为 pyinstaller 命令的参数，则加入到自定义参数中去。
                param=${param}" "${SOURCE[i]}
                if pyinstaller --help | grep -wE "^\s*${SOURCE[i]} \S+" &>/dev/null; then
                    # 如果下一个参数是上一个参数的值，则进行追加
                    param=${param}" "${SOURCE[i + 1]}
                    i=$((i + 1))
                fi
            else
                echo "${SOURCE[i]} is not an option"
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
    forceExit
fi
for SOURCE in "${SOURCE_LIST[@]}"; do
    {
        SOURCEPATH="$SOURCE"
        workDir
        projectName=$(basename "$(pwd)")
        log1="${projectName}.centos5.log"
        log2="${projectName}.centos6.log"
        log3="${projectName}.linux.log"
        echo "DEBUG: 当前所在的工作目录为：$(pwd)" | tee "$log1" "$log2" "$log3"
        if [[ $envFlag -eq 1 ]]; then
            setEnv | tee "$log1" "$log2" "$log3"
        fi
        if [[ $runFlag -eq 1 ]]; then
            runDocker
        fi
    } &
done
wait
reDir
