#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" 对项目的Lua 库， 尝试进行单元测试"""

import os.path
import sys


def run_test(lib_path, luabin, file):
    command = 'LUA_PATH="%s/?.lua" %s %s' %(lib_path, luabin, file)
    print("RUN: ", command)
    status = os.system(command)
    if status != 0:
        raise Exception("UNITEST FAILED, file: %s" %(file))

def main(luabin, lib_path):
    for root, dirs, files in os.walk(lib_path, topdown=True):
        for file in files:
            if file.endswith('_test.lua'):
                file_path = os.path.join(root, file)
                run_test(lib_path, luabin, file_path)


if __name__ == '__main__':
    luabin = sys.argv[1];
    lib_path = sys.argv[2]
    main(luabin, lib_path)