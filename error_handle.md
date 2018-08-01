# 错误处理

CabalPHP 支持自定义异常处理和 404，405等错误处理。

!> 请求中的错误处理请写在 `usr/routes.php` 中！


## 404处理
可以在 `usr/routes.php`中自定义404处理，如果不配置会返回缺省404页面。

```php
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$dispatcher->registerMissingHandler(function (Server $server, Request $request, $vars = []) {
    // code...
});

```
## 405处理
可以在 `usr/routes.php`中自定义405处理，如果不配置会返回缺省405页面。

```php
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$dispatcher->registerMethodNotAllowHandler(function (Server $server, Request $request, $vars = []) {
    // code...
});

```

## 控制器异常处理
可以在 `usr/routes.php` 中自定义控制器中的异常处理，如果不配置会返回缺省500页面。

```php
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$dispatcher->registerExceptionHandler(function (Server $server, \Exception $ex, $chain, Request $request, $vars = []) {
    $response = new Response('php://memory', 500);
    $body = '';
    if ($server->debug()) {
        $body = '<pre>' . $ex->__toString() . '</pre>';
    }
    $response->getBody()->write('<html><head><title>500 Internal Server Error</title></head><body bgcolor="white"><h1>500 Internal Server Error</h1>' . $body . '</body></html>');
    return $response;
});

```


## 异步任务异常处理

可以在 `usr/tasks.php` 中自定义异步任务的异常处理，默认会将错误记录的日志文件中。
```php
use Cabal\Core\Http\Server;

$dispatcher->registerExceptionHandler(function (Server $server, \Exception $ex, $taskId, $workerId, $vars = []) {
    // code..
});

```

