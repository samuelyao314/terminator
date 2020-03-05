#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" 生成项目的部署文件夹 """

import os.path
import os
import shutil
import glob
import sys
import hashlib

def file_is_same(srcfile, destfile, comparator):
    return comparator(srcfile, destfile)

def get_file_md5(f):
    m = hashlib.md5()
    while True:
        data = f.read(10240)
        if not data:
            break
        m.update(data)
    return m.hexdigest()

def md5_cmp(srcfile, destfile):
    src_md5 = ""
    with open(srcfile, 'rb') as f:
        src_md5 = get_file_md5(f)
    with open(destfile, 'rb') as f:
        dest_md5= get_file_md5(f)
    return src_md5 == dest_md5

def copyfile(srcfile, destfile):
    assert(os.path.exists(srcfile))
    if not os.path.exists(destfile):
        path = os.path.dirname(destfile)
        if not os.path.exists(path):
            os.makedirs(path)
        shutil.copy2(srcfile, destfile)
        print(srcfile, "####", destfile)
        return
    # 存在差异，才进行覆盖
    same = file_is_same(srcfile, destfile, md5_cmp)
    if not same:
        shutil.copy2(srcfile, destfile)
        print(srcfile, "--->", destfile)


def copydir(project_dir, srcdir, deploy_dir, destdir, extension, exclude):
    """
    同步指定格式的文件.
    遍历真实路径 ${project_dir}/${srcdir}.  如果找到文件  ${project_dir}/${srcdir}/xxx/yyy/z.lua,
    目标路径是 ${deploy_dir}/${destdir}/xxx/yyy/z.lua,

    :param project_dir: 项目根目录
    :param deploy_dir: 部署目录
    :param srcdir:  遍历目录 （相对 project_dir)
    :param destdir:  目标目录 （相对 deploy_dir)
    :param extension: 文件后缀
    :param exclude: 需要忽略的子目录
    """
    src_path = os.path.join(project_dir, srcdir)
    dest_path = os.path.join(deploy_dir, destdir)
    for root, dirs, files in os.walk(src_path, topdown=True):
        if exclude:
            if isinstance(exclude, str) and exclude == "*":   # 跳过所有子目录
                dirs[:] = []
            else:
                assert(isinstance(exclude, list))
                remove_dirs = []
                for d in dirs:
                    for key in exclude:
                        if d.endswith(key):  # 判断指定后缀的目录
                            # print("skip", root, d)
                            remove_dirs.append(d)
                for d in remove_dirs:
                    dirs.remove(d)
        for file in files:
            if extension != "*" and (not file.endswith(extension)):
                continue    # 不复制这个文件
            if file.endswith("_test.lua"):   # 忽略单元测试文件
                continue
            srcfile = os.path.join(root, file)
            destfile = srcfile.replace(src_path, dest_path)
            copyfile(srcfile, destfile)


def main(project_dir, deploy_dir):
    """
    :param project_dir:  项目的根目录
    :param deploy_dir: 部署二进制程序的目录
    :return:
    """
    if not os.path.exists(deploy_dir):
        os.makedirs(deploy_dir)
    builddir = os.path.join(project_dir, "build")
    if not os.path.exists(builddir):
        os.makedirs(builddir)

    # 格式：起启文件路径，目标文件路径
    files = [
        ("skynet/skynet",  "skynet"),
        ("skynet/3rd/lua/lua", "skynet"),
        ("skynet/3rd/lua/luac", "skynet"),
        ("run.sh",  ""),
    ]
    for path, destdir in files:
        src_path = os.path.join(project_dir, path)
        name = os.path.basename(path)
        dest_path = os.path.join(deploy_dir, os.path.join(destdir, name))
        copyfile(src_path, dest_path)

    # 格式：起启路径，目标路径，文件后缀, 需要跳过的子目录； 支持递归
    dirs = [
        ("skynet/lualib", "skynet/lualib", ".lua", None),
        ("skynet/service", "skynet/service", ".lua", None),
        ("skynet/luaclib", "skynet/luaclib", ".so", [".dSYM"]),
        ("skynet/cservice", "skynet/cservice", ".so", [".dSYM"]),
        ("luaclib", "luaclib", ".so", "*"),   # 星号， 标示不遍历子目录
        ("service",  "service", ".lua", None),
        ("lualib","lualib", ".lua", None),
        ("etc", "etc", '*', None),       # 第2个星号，忽略文件后缀，复制所有的文件
    ]

    for srcdir, destdir, extension, exclude in dirs:
        copydir(project_dir, srcdir, deploy_dir, destdir, extension, exclude)

if __name__ == "__main__":
    project_dir = sys.argv[1]
    deploy_dir = sys.argv[2]
    main(project_dir, deploy_dir)
