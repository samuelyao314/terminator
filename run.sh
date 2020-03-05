if [ $# -lt 1 ]
then
    echo 请输入配置名，如:run.sh test
    exit
fi

skynet/skynet etc/config.$1
