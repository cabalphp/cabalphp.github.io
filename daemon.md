# 进程守护

建议使用 systemd 管理我们的服务进程。

- 可以参考[swoole官方文档](https://wiki.swoole.com/wiki/page/699.html)

## 使用方法

1. 请确保`cabal.php`配置文件中的`swoole.daemonize`配置为关闭状态（`0`或`false`）！
```php
    'swoole' => [
        // ...
        'daemonize' => 0,
        // ...
    ],
```
2. 在 `/etc/systemd/system/`目录中，创建一个 `cabal.service` 文件，添加下列内容（**注意修改php和项目路径**）：
```php
    [Unit]
    Description=Cabal Server
    After=network.target
    After=syslog.target

    [Service]
    Type=simple
    LimitNOFILE=65535
    ExecStart=/usr/local/php/bin/php /data/srv/demo/bin/cabal.php -e prod
    ExecReload=/bin/kill -USR1 $MAINPID
    Restart=always

    [Install]
    WantedBy=multi-user.target graphical.target
```
**可以在 `Server`下增加两个配置下指定用户（`User=xxx`）和用户组（`Group=myuser`）哦!**

3. 重新加载 systemd 
```bash
    sudo systemctl --system daemon-reload
```

4. 服务管理
```bash
    #启动服务
    sudo systemctl start cabal
```
```bash
    #reload服务
    sudo systemctl reload cabal
```
```bash
    #关闭服务
    sudo systemctl stop cabal
```
```bash
    #查看服务状态
    sudo systemctl status cabal
```

5. 查看服务日志
```bash
    # 从头开始看所有日志
    journalctl -u cabal
    # 最后100条
    journalctl -u cabal -n 100
    # 最后100条且跟踪日志（有新日志会立刻输出到屏幕，类似 tail -f / tailf）
    journalctl -u cabal -n 100 -f
```
`journalctl` 还有很多其他查询日志的方法，请自行查阅相关文档资料。



至此你的服务就可以稳定的运行啦！