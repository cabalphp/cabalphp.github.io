# 任务


## 方法说明

可以通过 `$server->task(Chain $chain, $dstWorkerId = -1)` 投递任务


handler 执行完后如果返回一个 `Cabal\Core\Chain` 对象则系统会在worker进程中自动调用对应的 handler 方法，

**如果执行的任务不需要回调行为请不要返回任何值！**

----

`Cabal\Core\Chain` 对象构造函数如下 

```php
namespace Cabal\Core;

class Chain
    public function __construct($handler, $middleware, $vars = []){}
}
```

 * $handler 投递的任务handler必须是字符串 className@method 或者 className@staticMethod
 * $middleware 需要执行的中间件名称，数组或字符串(单个中间件可以用字符串)
 * $vars 对应handler方法的最后一个变量

!> 传入的方法数据必须是可以被序列化的内容，不能使资源类内容！


## 投送任务

**一个投递任务的例子：**

```php
namespace App\Task

use Cabal\Core\Chain;

class TestController
{
    public function task(\Server $server, $taskId, $workerId, $vars = [])
    {
        echo date('Y-m-d H:i:s') . ' vars: ' . json_encode($vars) . "\r\n";
        sleep(1); 
        // 其他阻塞代码 ...
        // 比如发送邮件、磁盘写等
        // 此处获取的 $server->db() 或者 $server->cache() 都是阻塞对象


        // return Chain 则会执行回调方法
        return new Chain('App\Task\TestController@finish', [], [uniqid()]);
    }

    public function finish(\Server $server, $taskId, $vars = [])
    {
        // 此处在 worker 进程执行，请注意不要有阻塞代码
        // 此处获取的 $server->db() 或者 $server->cache() 都是swoole协程的非阻塞对象
        echo date('Y-m-d H:i:s') . ' vars: ' . json_encode($vars) . "\r\n";
    }
}


// 投入任务
$server->task(new Chain('App\Task\TestController@task', [], [1, 2]));
```



以上代码会在控制台输出

    2018-08-01 18:23:45 vars: [1,2]
    2018-08-01 18:23:46 vars: ["5b618a32d473b"]


?> tasker 或者 worker 进程中的数据库操作和缓存操作语法都一样，你没有什么需要注意的




## 定时任务

如果你需要执行定时任务，你可以在在 `usr/tasks.php` 文件中用 `$server->tick` 方法创建计时器，你可以在匿名函数内使用 `Chain` 对象执行其他类的方法。



```php
$chain->execute(array $params);
```

 * $params 是调用方法的参数，类似 `call_user_func_array($callback, $param_arr)` 方法的第二个参数 execute会在 `$params` 最后加构造时传入的 `$vars`


**一个简单的例子：**

```php
namespace App\Task

use Cabal\Core\Chain;

class TickController
{
    public function task(\Server $server, $workerId, $vars = [])
    {
        echo date('Y-m-d H:i:s') . ' workerId: ' . $workerId  . ' vars: ' . json_encode($vars) . "\r\n";
        sleep(1); 
        // 其他阻塞代码 ...
        // 比如发送邮件、磁盘写等
        // 此处获取的 $server->db() 或者 $server->cache() 都是阻塞对象
    }

}

// 计时器
$server->tick( 1000, function () use ($server) {
    $chain = new Chain('App\Task\TestController@task', [], [1,2,3]);
    $chain->execute([$server, $taskId, $workerId]);
});

```
