#!/bin/bash
##################################依赖##################################
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

ipvs-set-on() {
    if [ "$(get_sys)" == "Ubuntu" ]; then
        for i in $(ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipvs | grep -o "^[^.]*"); do
            echo "$i"
            /sbin/modinfo -F filename $i >/dev/null 2>&1 && /sbin/modprobe $i
        done
        ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipvs | grep -o "^[^.]*" >>/etc/modules
        # 去除重复
        var_file=/etc/modules && awk '!a[$0]++' ${var_file} >${var_file}.tmp && mv -f ${var_file}.tmp ${var_file}
        sudo sysctl -p
        lsmod | grep ip_vs

    elif [ "$(get_sys)" == "CentOS" ]; then
        cat >/etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
        chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

    fi

}

ipvs-set-off() {
    echo -e "\e[1;31mNot currently supported\e[0m"

}

####################################################################
while
    getopts :och OPT
do
    case $OPT in

    o)
        ipvs-set-on
        ;;

    c)
        ipvs-set-off
        ;;

    h)
        dis=$(
            cat <<-EOF

\e[1;42m参数：\e[0m
        -o      # 开启
        -c      # 关闭

 
EOF
        )

        echo -e "${dis}"
        ;;

    :)  #当选项后面没有参数时，OPT的值被设置为（：），OPTARG的值被设置为选项本身
        echo "-$OPTARG 选项需要参数" #提示用户此选项后面需要一个参数
        exit 1
        ;;

    ?)  #当选项不匹配时，OPT的值被设置为（？），OPTARG的值被设置
        echo "无效的选项: -$OPTARG" #提示用户此选项无效
        exit 2
        ;;

    esac

done
