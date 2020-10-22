#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" 根据模版生成服务 """
import sys
import os
import os.path
import multiprocessing

# cpu 核数
CPU_COUNT = multiprocessing.cpu_count()

ETC_TEMLATE = """-- {0}
thread = 1     -- 启动多少个线程
harbor = 0     -- 单节点
lualoader = "lualib/loader.lua"   -- 不建议修改
bootstrap = "snlua bootstrap"   -- 不建议修改

start = "{2}"  -- 入口脚本

-- 日志配置，默认打印到标准输出
logservice = "logger"
logger = nil

lua_cpath = "../luaclib/?.so;luaclib/?.so"
lua_path =  "../lualib/?.lua;../lualib/3rd/?.lua;lualib/?.lua;"

snax = "../service/?.lua;../service/?/init.lua;service/?.lua"
luaservice = "../service/?.lua;../service/?/init.lua;service/?.lua;examples/?.lua"
cpath = "../cservice/?.so;cservice/?.so"
"""

def generate_etc(svr_name, infomation):
    content = ETC_TEMLATE.format(information, CPU_COUNT, svr_name)
    path = "etc"
    if not os.path.exists(path):
        #os.makedirs(path)
        print("root dir must has 'etc' directory\n")
        sys.exit(1)
    filename = os.path.join(path, "%s_conf.lua"  %(svr_name))
    with open(filename, "w") as fp:
        fp.write(content)


SVR_INIT_TEMPLATE ="""
--  功能: {1}

local skynet = require "skynet"
local socket = require "skynet.socket"


skynet.start(function()
    skynet.error("-----------start {0} server.----------------")
end)

"""

def generate_svr(svr_name, information):
    content = SVR_INIT_TEMPLATE.format(svr_name, information)
    path = "service/%s" %(svr_name)
    if not os.path.exists(path):
        os.makedirs(path)
    filename = os.path.join(path, "init.lua")
    if os.path.exists(filename):
        raise Exception("service exist, %s" %(svr_name))
    with open(filename, "w") as fp:
        fp.write(content)


def main(svr_name, information):
    generate_etc(svr_name, information)
    generate_svr(svr_name, information)

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("usage: %s <server_name> <服务说明>\n", sys.argv[0])
        print("例如: python new_service.py hellosvr 测试程序\n")
        sys.exit(0)
    svr_name = sys.argv[1]
    information = sys.argv[2]
    main(svr_name, information)
