#!/bin/bash

# Info    : 主机组远程执行命令
# Args 1  : 主机组
# Args 2  : 远程命令


function Init()
{
    MysqlBin='mysql --port 3306 -h 192.168.10.55 -uokooo -p'11111' okops '
}

function Help()
{
    echo -e "\e[1;31m该脚本必须输入两个参数！\e[0m"
    echo -e "\e[1;32m参数1\e[0m：需要检查的主机组; 如：\e[1;35mweb\e[0m"
    echo -e "\e[1;32m参数2\e[0m: 需要执行的命令;   如：\e[1;35m'ls -l /logs'\e[0m 若命令含有空格请使用单引号括住"
}

function RunCMD()
{
        for host in `eval echo $1`
	do
		#IP=`grep -w $host /etc/hosts | awk '{print $1}'`
		IP=`dig -t A  ${host}.okooo.cn | grep ^${host} | awk '{print $5}'`
		if [ "$IP" != "" ];then
	    echo -e "\n\e[1;33m===================\e[0m \e[1;32mServer:\e[0m \e[1;31m$host \e[0m| \e[1;32mIP:\e[0m \e[1;31m$IP\e[0m \e[1;33m===================\e[0m"
	    /usr/bin/ssh $host "$2"
	    else
	    echo -e "\n\e[1;33m===================\e[0m \e[1;32mServer:\e[0m \e[1;31m$host \e[0m| \e[1;32mIP:\e[0m \e[1;31m dns未注册\e[0m \e[1;33m===================\e[0m"
            /usr/bin/ssh $host "$2"
	    fi
	    
	done
}

# ============ Main ============
Init

if [ "$1" == "" ] || [ "$2" == "" ];then
    Help
    groups=`$MysqlBin -e "select GroupName from hostgroups"|sed '1d'`
    echo "$groups"
    exit 1
else
    HostGroup=$1
    if [[ "$1" == 'all' ]];then
	hosts=`$MysqlBin -e "select HostName from hosts where InService=1 order by HostName"| sed '1d' | xargs`
    else 
	hosts=`$MysqlBin -e "select HostName from hosts where HostID in (select managehosts_id from host_group_relation where managehostgroups_id=(select GroupID from hostgroups where GroupName='$HostGroup')) and InService=1 order by HostName;" | sed '1d' | xargs`
	if [ -z "$hosts" ];then
	    echo "$HostGroup not exists,use list:"
	    groups=`$MysqlBin -e "select GroupName from hostgroups"|sed '1d'`
	    echo "$groups"
	fi
    fi
    RunCMD "$hosts" "$2"
fi