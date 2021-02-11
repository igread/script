#!/bin/bash
# DATE: 2020-12-31 16:58:42
# FileName:     sources_update.sh
# Description:  NULL
# Depend:       get_sys.sh
#

function sources_update() {

    ##################################支持文件##################################
    function get_sys() {
        if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
            DISTRO='CentOS'
        elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
            DISTRO='RHEL'
        elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
            DISTRO='Aliyun'
        elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
            DISTRO='Fedora'
        elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
            DISTRO='Debian'
        elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
            DISTRO='Ubuntu'
        elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
            DISTRO='Raspbian'
        else
            DISTRO='1'
        fi
        ###返回值
        echo ${DISTRO}
    }

    #################################################################################

    if [ "$(get_sys)" == "CentOS" ]; then
        sudo yum install -y epel-release
        sudo sed -e 's|^metalink=|#metalink=|g' \
            -e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
            -i.bak \
            /etc/yum.repos.d/epel.repo

    elif

        [ "$(get_sys)" == "Ubuntu" ]
    then
        cp /etc/apt/sources.list /etc/apt/sources.list."$(date +"%Y%m%d%H%M%S")".bak
        cat >/etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF

        tmp_fh=$?
        [[ $tmp_fh == 0 ]] && echo -e "\e[1;32m成功\e[0m"
        [[ $tmp_fh == 0 ]] || echo -e "\e[1;31m失败\e[0m"

    fi

}

sources_update