#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" 对项目的Lua 库， 尝试进行单元测试"""

import os.path
import sys


def run_test(lib_path, luabin, file):
    command = 'LUA_PATH="%s/?.lua" LUA_CPATH="luaclib/?.so" %s %s' %(lib_path, luabin, file)
    print("RUN: ", command)
    status = os.system(command)
    if status != 0:
        raise Exception("UNITEST FAILED, file: %s" %(file))

def main(luabin, lib_path, rootdir):
    for root, dirs, files in os.walk(rootdir, topdown=True):
        for file in files:
            if file.endswith('_test.lua'):
                file_path = os.path.join(root, file)
                run_test(lib_path, luabin, file_path)


if __name__ == '__main__':
    luabin = sys.argv[1];
    lib_path = sys.argv[2]
    rootdir = "."
    if len(sys.argv) >= 4:
        rootdir = sys.argv[3]
    main(luabin, lib_path, rootdir)