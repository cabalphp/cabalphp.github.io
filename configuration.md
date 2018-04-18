# 配置
CabalPHP 所有配置文件都保存在 conf 目录中，配置文件均采用 php 格式。

## 支持的配置项

### cabal.php
```php
return [
    // 是否开启调试
    'debug' => false,

    // 监听主机 默认为 `127.0.0.1`
    'host' => '127.0.0.1',

    // 监听端口 默认为 `9501`
    'port' => '9501',

    // swoole_server 的运行的模式 详情请查看swoole文档
    'mode' => '3',

    // 路由文件配置 默认为  usr/routes.php 一个文件，你可以根据自己的需要配置一个或多个
    'routes' => [
        'usr/routes1.php',
        'usr/routes2.php',
        'usr/routes3.php',
    ],

    // swoole 块下的配置是所有的swoole支持的配置选项写法和swoole配置项同名即可
    'swoole' => [
        //设置启动的worker进程数。
        'worker_num' => 4,
    ],
];
```
> 相关参考文档 
[swoole 运行模式文档](https://wiki.swoole.com/wiki/page/14.html)，
[swoole 配置选项文档](https://wiki.swoole.com/wiki/page/274.html)

## 环境配置

将对应的配置文件放到 `conf/环境名/` 下即可，系统会优先读取环境名目录下的配置文件。

例如增加 `conf/dev/cabal.php` 文件，文件内容如下：

``` php
return [
    'port' => '8080',
];
```

运行：
```bash
./bin/cabal -e dev start
```
服务将会启动在 http://127.0.0.1:8080/ 。

