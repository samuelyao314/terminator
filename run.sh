if [ $# -lt 1 ]
then
    echo 请输入配置名，如:run.sh test
    exit
fi

cd skynet; ./skynet ../etc/$1_conf.lua
