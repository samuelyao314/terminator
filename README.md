## 介绍
terminator 是基于 [skynet](https://github.com/cloudwu/skynet) 服务端开发方案.

## 编译和运行
项目支持在 Linux 和 MacOS 下编译。 
需要提前安装构建工具 cmake,  以及 python.

编译项目

```shell
$ git clone https://github.com/samuelyao314/workspace terminator
$ cd terminator
$ make

```

下一步，运行服务

```shell
$ ./run.sh test # test 是服务名
```


如果需要部署，执行

```shell
$ make dev
```

最后，复制 deploy 目录到目标机器。


## 项目结构

```
lualib(公共lua库)
  bw (基于skynet的公共库)
	  hotfix (热更新机制)
	base(通用库)
	perf(性能相关）
	test(单元测试)
  3rd (切记：不要在这里放文件，会被删除)
etc(启动配置)
  config.test  (test 服务配置)
  config.chat  (chat 服务配置)
service(服务入口)
  test (简单测试服务)
  chat  (聊天服务)
skynet(fork skynet项目，不作任何改动)
tools(辅助工具)
	deploy.py (生成部署目录)
	unittest.py. (单元测试驱动)
	new_service.py  (创建自定义服务)
thirdparty. (第三方依赖)

```


## 创建新服务
新的项目，通常都需要创建新服务。一般情况，用模版工具生成。

```shell
$ python tools/new_service.py hello "just test"   # 参数1是服务名称（保证唯一），参数2是描述信息
```

执行后，会生成以下文件。如果需要删除服务，手动清除以下文件。

```
etc
    config.hello  (配置)
service
    hello
        init.lua (服务的入口)
```

接着，启动新服务

```
    $ ./run.sh hello
```

启动后，当前目录会更改为， skynet/skynet 所在的目录。




## 代码规范
使用 luacheck进行代码质量检查，配置文件.luacheckrc. 

安装完 luacheck 后 （建议用 hererock + luarocks 进行安装）

```shell
$ make check
```

## 单元测试
单元测试文件，  是以   xx_test.lua 命名的文件。 
执行单元测试

```shell
$ make test
```

## 代码热更新
热更新机制可以在开发阶段，帮忙更好地调试代码。
因为Lua的灵活性以及游戏逻辑的复杂，热更新很难做完备，因此不建议应用在生产环境。
生产环境，需要临时修复代码，可以用 skynet 自带的 inject 机制。

启动热更新，需要配置当前环境为开发环境

```lua
	# config 文件
	run_env="dev"
```

接着，**import**  加载的文件，一旦文件被修改，就会自动热加载。

```lua
	local mod = import("mod")
```

更多细节看  services/service/hotfix.


## 配置热更新
*TODO*


## 单步调试
结合 VSCode 的插件[Skynet Debugger](https://github.com/colinsusie/skynetda), 本项目支持单步调试。 

例如服务 chat，进行单步调试。 VSCode 的配置文件 launch.json 设置如下

```json
{
    // 这个版本号，根据实际的插件版本号，进行修改
    "version": "1.0.0",
    "configurations": [
        {
            "name": "skynet debugger",
            "type": "lua",
            "request": "launch",
            "program": "${workspaceFolder}/skynet",
            "config": "../etc/config.chat"
        }
    ]
}
```

启动配置 config.chat 里，确定有以下4行配置

```lua
logger = "vscdebuglog"
logservice = "snlua"
vscdbg_open = "$vscdbg_open"
vscdbg_bps = [=[$vscdbg_bps]=]
```

然后，点击菜单：Debug-Start Debugging. 最后就可以设置断点，进行调试了。

## 内存泄露
内存泄露，可以通过2次对Lua State 进行切片，比较差异，就可以得到内存是否存在泄露。
具体的接口使用见例子 perf .

``` shell
$ ./skynet ../etc/config.perf
# 启动后，在当前目录，这个服务会产生一个内存切片。
# 例如产生类似这种文件：LuaMemRefInfo-All-[XXX]-[simulate_memory:00000008].txt。
# 等待少许时间，该服务会分配一些对象
# debug_console 服务提供了管理端工具，通过它再生成一份切片
$ telnet 127.0.0.1 8000
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
call 8 "dump_memory",1,2    # 这个是输入, 8 代表perf服务的ID
n	0     # 这个是返回
<CMD OK>

# 下一步，利用2个切片文件，得到内存差异
$ 3rd/lua/lua ../tools/compare_memory_snapshot.lua LuaMemRefInfo-All*
# 当前目录会生成一个  LuaMemRefInfo-All-[XXX]-[Compared].txt
# 比较代码，以及这个差异，就可以知道是否存在内存泄露

```

具体实现细节见：[关于 Lua 内存泄漏的检测](https://www.cnblogs.com/yaukey/p/unity_lua_memory_leak_trace.html)

## 火焰图
*TODO*


##  第三方模块
* [lua-zset](https://github.com/xjdrew/lua-zset), Lua 的sorted set实现。基于Redis 的skiplist源码
* [lua-cjson](https://github.com/openresty/lua-cjson), 高性能的JSON解析器和编码器
* [lua-cmsgpack](https://github.com/antirez/lua-cmsgpack), C语言实现的msgpack解析器和编码器
* [luafilesystem](https://github.com/keplerproject/luafilesystem), lua的一个专门用来进行文件操作的库
* [lua-protobuf](https://github.com/starwing/lua-protobuf/), XLua 作者实现的PB解析库。[文档在这里](https://zhuanlan.zhihu.com/p/26014103)

## 参考资料
* [bewater](https://github.com/zhandouxiaojiji/bewater),  skynet通用模块
* [RillServer](https://github.com/cloudfreexiao/RillServer)，skynet 游戏框架
