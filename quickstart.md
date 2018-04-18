# 快速开始


## 安装

### composer快速安装

建议适用国内镜像

```bash
composer create-project cabalphp/cabal-skeleton
```
### 手动安装

```bash
git clone git@github.com:cabalphp/skeleton.git
cd cabal-skeleton
composer install
```

## 运行

```bash
./bin/cabal start
```

?> 支持传入参数 `-e 运行环境` 如: `./bin/cabal -e dev start` 将以dev环境运行，默认为prod环境。

?> 监听端口和IP请参见文档的 [配置章节](https://github.com/QingWei-Li/docsify-cli).

运行后访问 http://127.0.0.1:9501/ 可见到下面页面

![](/_media/home.png)

## Mac 开发环境下自动热更新

```bash
./bin/cabal-listen
```

文件修改保存后会自动reload。


## 文件夹结构

* `bin` 可执行文件存放目录
* `conf` 配置文件存放目录
* `lib` 第三方类库文件夹，如果第三方类库无法使用composer安装请放在这里面。
* `test` 目录包含自动化测试文件
* `usr` 你项目的业务代码文件夹包含：**路由、控制器、模型、领域逻辑代码**等
* `var` 资源文件和存储文件等
* `vendor`  Composer 依赖包存放目录

