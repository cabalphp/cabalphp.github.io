# 扩展阅读


##  CentOS 系统配置优化

* net.ipv4.tcp_tw_recycle
    * 使用socket快速回收，短连接Server需要开启此参数。此参数表示开启TCP连接中TIME-WAIT sockets的快速回收，Linux系统中默认为0，表示关闭。**打开此参数可能会造成NAT用户连接不稳定，请谨慎测试后再开启。**
* net.ipv4.tcp_tw_reuse
    * 此项的作用是Server重启时可以快速重新使用监听的端口。如果没有设置此参数，会导致server重启时发生端口未及时释放而启动失败
* overcommit_memory
    * 定义了系统中每一个端口最大的监听队列的长度,这是个全局的参数,默认值为128.限制了每个端口接收新tcp连接侦听队列的大小。对于一个经常处理新连接的高负载 web服务环境来说，默认的 128 太小了。大多数环境这个值建议增加到 1024 或者更多。 服务进程会自己限制侦听队列的大小(例如 sendmail(8) 或者 Apache)，常常在它们的配置文件中有设置队列大小的选项。大的侦听队列对防止拒绝服务 DoS 攻击也会有所帮助。
* vm.overcommit_memory 
    * 设置内存分配策略，redis推荐打开配置
        * 0， 表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。
        * 1， 表示内核允许分配所有的物理内存，而不管当前的内存状态如何。
        * 2， 表示内核允许分配超过所有物理内存和交换空间总和的内存


执行下面命令使配置立刻生效：

```bash
# 请酌情配置
# sysctl -w net.ipv4.tcp_tw_recycle=1
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.core.somaxconn=1024
sysctl -w vm.overcommit_memory=1
```


修改 `/etc/sysctl.conf` 增加一下配置，使服务器重启配置后仍然生效
```
# 请酌情配置
# net.ipv4.tcp_tw_recycle=1
net.ipv4.tcp_tw_reuse=1
net.core.somaxconn=1024
vm.overcommit_memory=1
```