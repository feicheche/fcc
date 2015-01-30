#!/bin/bash

date185=`date --date "185 days ago" +"%Y-%m-%d %T"`
date95=`date --date "95 days ago" +"%Y-%m-%d %T"`
date15=`date --date "15 days ago" +"%Y-%m-%d %T"`

user=user
passwd='passwd'

dw_user=dw_user
dw_passwd='dw_passwd'

logfile='/tmp/archive.log'

while read line
do
read InstanceName InstanceIP InstancePort DbName TableName KeyId KeyTime<<< $(echo $line|awk '{print $1,$2,$3,$4,$5,$6,$7}')

	if [ $TableName = "bet_match_belong" ] || [ $TableName = "wager_bet_match_belong" ];then
		echo "`date +"%Y-%m-%d %T"` $InstanceName start"
		sleep 1
		keyid=`mysql -h$InstanceIP -u$user -p$passwd --port=$InstancePort \
		-e "use $DbName; select min($KeyId) from $TableName where $KeyTime > '$date15'" | awk 'NR==2 {print}' `
		time pt-archiver --source h=$InstanceIP,p=$passwd,P=$InstancePort,u=$user,D=$DbName,t=$TableName \
		--dest h=192.168.12.76,p=$dw_passwd,P=3366,u=$dw_user,D=del_bak,t=$InstanceName --where "$KeyId <= $keyid" --limit 10000 \
		--commit-each --no-check-charset --progress=10000 --statistics >> $logfile 2>&1
		sleep 1
		echo "`date +"%Y-%m-%d %T"` $InstanceName complete!"
	elif [ $TableName = "score_freeze" ] || [ $TableName = "FreezeDetail" ]; then
		echo "`date +"%Y-%m-%d %T"` $InstanceName start"
		sleep 1
		time pt-archiver --source h=$InstanceIP,p=$passwd,P=$InstancePort,u=$user,D=$DbName,t=$TableName \
		--where "$KeyId = 'Y'" --limit 10000 --commit-each --purge --no-check-charset --progress=10000 --statistics >> $logfile 2>&1
		sleep 1
		echo "`date +"%Y-%m-%d %T"` $InstanceName complete!"
	elif [ $TableName = "app_active" ]; then
		echo "`date +"%Y-%m-%d %T"` $InstanceName start"
		sleep 1
		keyid=`mysql -h$InstanceIP -u$user -p$passwd --port=$InstancePort \
		-e "use $DbName; select min($KeyId) from $TableName where $KeyTime > '$date95'" | awk 'NR==2 {print}' `
		time pt-archiver --source h=$InstanceIP,p=$passwd,P=$InstancePort,u=$user,D=$DbName,t=$TableName \
		--dest h=192.168.12.76,p=$dw_passwd,P=3366,u=$dw_user,D=del_bak,t=$InstanceName \
		--where "$KeyId <= $keyid" --limit 10000 --commit-each --no-check-charset --progress=10000 --statistics >> $logfile 2>&1
		sleep 1
		echo "`date +"%Y-%m-%d %T"` $InstanceName complete!"
	else
		echo "`date +"%Y-%m-%d %T"` $InstanceName start"
		sleep 1
		keyid=`mysql -h$InstanceIP -u$user -p$passwd --port=$InstancePort \
		-e "use $DbName; select min($KeyId) from $TableName where $KeyTime > '$date185'" | awk 'NR==2 {print}' `
		time pt-archiver --set-vars='set session sql_log_bin=0' --source h=$InstanceIP,p=$passwd,P=$InstancePort,u=$user,D=$DbName,t=$TableName \
		--dest h=192.168.12.76,p=$dw_passwd,P=3366,u=$dw_user,D=del_bak,t=$InstanceName \
		--where "$KeyId <= $keyid" --limit 10000 --commit-each --no-check-charset --progress=10000 --statistics >> $logfile 2>&1
		sleep 1
		echo "`date +"%Y-%m-%d %T"` $InstanceName complete!"
	fi

done < /root/bin/mysql_archive/config/archive.conf