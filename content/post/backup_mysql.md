+++
draft = true
date = "2017-03-24T14:49:18+08:00"
title = "备份mysql数据库的shell脚本"
categories = ["java"]
tags = ["Java","Language"]
+++

领导说每天都需要备份一下mysql，好吧，我总不能天天手动去弄，所以我自己写了一份shell脚本用来自动备份，crontab还是很好的呵呵
```
#! /bin/bash
#define mysql path
MYSQL_BIN_PATH=/local/akazam/servers/akazamdb51/bin #这个是你MYSQL的安装目录
MYSQL_BACKUP_PATH=/local/akazam/mysqlbak#你要备份的目录
SOCKET_FILE=/tmp/mysql.sock
if [ $# -eq 0 ]; then
    echo "ERROR:Usage:please input mysql arguments" 1>&2
    echo "The arguments like this" 1>&2`
    echo "./mysqlbackup.sh database [user][password] [port][bakpath]" 1>&2
    echo "default user is akazam ,default password is dbacc355 and" 1>&2
    echo "default port is 3306,if you all understand ,you can try now!" 1>&2
    exit 1
fi

#get datebase
db=$1
#get user
if [ "$2" = "" ]
then
user="akazam"
else
user=$2
fi
#get password
if [ "$3" = "" ]
    then
        password="dbacc355"
    else
        password=$3
fi
#get port
if [ "$4" = "" ]
    then
        port="3306"
    else
        port=$4
fi
#get backpath
if [ "$5" = "" ]
    then
        backpath=$MYSQL_BACKUP_PATH
    else
        backpath=$5
fi
#get the day before yesterday
byd=$(date --date='1 days ago' "+%Y%m%d")
#get today
today=$(date +%Y%m%d)
#backup today's mysqldump
if [ ! -d $MYSQL_BACKUP_PATH ]
    then
         mkdir $MYSQL_BACKUP_PATH
fi
cd $MYSQL_BIN_PATH
./mysqldump -u$user -p$password -h localhost $db --socket=$SOCKET_FILE --opt>$backpath/$db$today
echo "backup result is:$bakresult"
#delete the day before's backup
rm -rf $backpath/$db$byd
echo "you delete backup mydqldump is $db$byd and need backup mysqldump is $db$today"
```


