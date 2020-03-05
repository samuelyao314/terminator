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

最后，复制 deploy 目录到测试服务机器。


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

执行后，会生成以下文件

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

如果要清理，手动删除以上生成的文件。


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
