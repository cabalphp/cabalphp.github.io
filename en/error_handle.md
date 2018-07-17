# Error handling
CabalPHP supports custom exception handling and error handling such as 404, 405.


## 404Processing
Support for custom 404 processing, if not configured will return the default 404 page.

```php
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$boot->getDispatcher()->registerMissingHandler(function (Server $server, Request $request, $vars) {
    // code...
});

```
## 404Processing
Support for custom 405 processing, if not configured will return the default 405 page.

```php
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$boot->getDispatcher()->registerMethodNotAllowHandler(function (Server $server, Request $request, $vars) {
    // code...
});

```

## Exception handling
Support for exception handling in custom controllers, if not configured will return the default 500 page.

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