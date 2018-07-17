# Daemon

Recommended to use systemd to manage our service processes. 

- See [Swoole documentation](https://wiki.swoole.com/wiki/page/699.html) 

## How to use 

1. Make sure the `swoole.daemonize` configuration in the `cabal.php` configuration file Is off state (`0` or `false`)! 
```php 
    'swoole' => [ 
        // ... 
        'daemonize' => 0, 
        // ... 
    ], 
``` 
2. In the `/etc/systemd/system/` directory, create a `` Cabal.service` file, add the following (**Note to modify php and project path**): 
```ini 
    [Unit] 
    Description=Cabal Server 
    After=network.target 
    After=syslog.target 

    [Service] 
    Type=simple 
    LimitNOFILE =65535 
    ExecStart=/usr/local/php/bin/php /data/srv/demo/bin/cabal.php -e prod
    ExecReload=/bin/kill -USR1 $MAINPID 
    Restart=always 

    [Install] 
    WantedBy=multi-user.target graphical.target 
``` 
**You can add two users to the configuration under `Server` (`User=xxx` ) and user group (`Group=myuser`) Oh!** 

3. Reload systemd 
```bash 
    sudo systemctl --system daemon-reload 
``` 

4. Service Management 
```bash 
    #Start 
    Service sudo systemctl start cabal 
``` 
```bash 
    #reload service 
    sudo systemctl reload Cabal 
``` 
```bash 
    # close the service 
    sudo systemctl STOP Cabal 
``` 
```bash 
    # check the service status 
    sudo systemctl status Cabal 
``` 

5. Check service Log
```bash 
    # See all logs from the beginning 
    journalctl -u cabal 
    # last 100 
    journallct -u cabal -n 100 
    # last 100 and trace the log (new log will be output to the screen immediately, similar to tail -f / tailf) 
    journalctl -u cabal -n 100 -f 
``` 
`journalctl` There are many other ways to query logs, please check the relevant documentation. 



At this point your service will run steadily!