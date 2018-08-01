# 日志

CabalPHP的日志系统用的是 Monolog 组件，我们改写了一下日志写入方法，用的是swoole的异步协程写入，避免阻塞。

!> 系统会将php的所有错误（E_ALL），转化成异常抛出，避免代码业务逻辑存在问题。

## 配置

日志配置在 `conf/cabal.php`中 
```php
    'logFile' => 'var/log/cabal.log',
    'logLevel' => \Monolog\Logger::DEBUG,
```


## 记录日志

```php
\Cabal\Core\Logger::emergency($message, array $context = []);
\Cabal\Core\Logger::alert($message, array $context = []);
\Cabal\Core\Logger::critical($message, array $context = []);
\Cabal\Core\Logger::error($message, array $context = []);
\Cabal\Core\Logger::error($exception, array $context = []); // 直接记录 Exception
\Cabal\Core\Logger::warning($message, array $context = []);
\Cabal\Core\Logger::notice($message, array $context = []);
\Cabal\Core\Logger::info($message, array $context = []);
\Cabal\Core\Logger::debug($message, array $context = []);
```

## 修改日志写入方式

你可以用`Logger::instance()`方法获取默认 Monolog 实例，增加或指定 Monolog 的写入方法：
```php
\Cabal\Core\Logger::instance()->pushHandler($handler);

\Cabal\Core\Logger::instance()->setHandlers(array $handlers);
```

更多方法请查看 [Monolog 文档](https://github.com/Seldaek/monolog);

## 自定义日志渠道

你可以用 `Logger::instance($name)` 创建一个自己的 Monologo 实例并指定写入方式，比如文件存储或者远程UDP传输都可以，具体请查看 [Monolog 文档](https://github.com/Seldaek/monolog);

```php
\Cabal\Core\Logger::instance('task')->pushHandler(
    new StreamHandler(
        $server->rootPath('var/log/task.log'),
        $server->configure('cabal.logLevel', \Monolog\Logger::DEBUG)
    )
);
```