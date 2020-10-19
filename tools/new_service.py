#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" 根据模版生成服务 """
import sys
import os
import os.path
import multiprocessing

# cpu 核数
CPU_COUNT = multiprocessing.cpu_count()

ETC_TEMLATE = """
-- {0}
thread = {1}
logger = nil
harbor = 0
lualoader = "skynet/lualib/loader.lua"
bootstrap = "snlua bootstrap"   -- The service for bootstrap

start = "{2}"

lua_cpath = "luaclib/?.so;skynet/luaclib/?.so"
lua_path =  "lualib/?.lua;skynet/lualib/?.lua;"
cpath = "cservice/?.so;skynet/cservice/?.so"
luaservice = "service/?/init.lua;skynet/service/?.lua"

preload="lualib/bw/preload.lua"
run_env="dev"
"""

def generate_etc(svr_name, infomation):
    content = ETC_TEMLATE.format(svr_name, CPU_COUNT, information)
    path = "etc"
    if not os.path.exists(path):
        os.makedirs(path)
    filename = os.path.join(path, "config.%s"  %(svr_name))
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
    # 服务名用 svr, 避免跟 lib 库名称冲突
    if not svr_name.endswith("svr"):
        print("<server_name> must end with 'svr'\n")
        sys.exit(0)
    information = sys.argv[2]
    main(svr_name, information)