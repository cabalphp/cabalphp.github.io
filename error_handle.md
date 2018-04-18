# 错误处理
CabalPHP 支持自定义异常处理和 404，405等错误处理。


## 404处理
支持自定义404处理，如果不配置会返回缺省404页面。

```php
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$boot->getDispatcher()->registerMissingHandler(function (Server $server, Request $request, $vars) {
    // code...
});

```
## 404处理
支持自定义405处理，如果不配置会返回缺省405页面。

```php
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$boot->getDispatcher()->registerMethodNotAllowHandler(function (Server $server, Request $request, $vars) {
    // code...
});

```

## 异常处理
支持自定义控制器中的异常处理，如果不配置会返回缺省500页面。

```php
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$boot->getDispatcher()->registerExceptionHandler(function (Server $server, \Exception $ex, $chain, Request $request, $vars) {
    $response = new Response('php://memory', 500);
    $body = '';
    if ($server->debug()) {
        $body = '<pre>' . $ex->__toString() . '</pre>';
    }
    $response->getBody()->write('<html><head><title>500 Internal Server Error</title></head><body bgcolor="white"><h1>500 Internal Server Error</h1>' . $body . '</body></html>');
    return $response;
});

```