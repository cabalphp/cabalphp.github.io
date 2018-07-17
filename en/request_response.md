# Request & Response


CabalPHP's Request and Response objects rely on [zendframework/zend-diactoros](https://github.com/zendframework/zend-diactoros) to implement [PSR-7 Standard](http://www.php-fig.org/psr/psr-7/) [psr/http-message](https://github.com/php-fig/http-message) `Psr\Http\Message\ServerRequestInterface` and `` All the interfaces of Psr\Http\Message\ResponseInterface` also extend their own practical methods conveniently and practically.


## Get request

You can get the request object with `\Psr\Http\Message\ServerRequestInterface` in PSR-7:
```php
$route->get('/hello/{name}', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return "hello " . $vars['name'];
});
```

You can also use `Cabal\Core\Http\Request` to get the request object:
```php
use Cabal\Core\Http\Request;
use \Cabal\Core\Http\Server;

$route->get('/hello/{name}', function (Server $server, Request $request, $vars = []) {
    return "hello " . $vars['name'];
});
```

?> Either way, you get a `Cabal\Core\Http\Request` object

?> The matching parameters in the routing rules are in the `$vars` variable.


## Get input parameters

CabalPHP will help you combine the GET parameters with the POST (data in the request body) parameters, giving priority to the parameters in POST.

* Get all the data:
```php
$request->all();
```

* Only get `username` and `password`, you can pass the array with the first argument:
```php
$request->only(['username', 'password']);
```

* Only get `username` and `password`, you can pass multiple parameters:
```php
$request->only('username', 'password');  
```

* Determine if it is an ajax request (X-Requested-With=XMLHttpRequest):
```php
$request->isXhr();
```

* Determine whether it is a request method (GET HEAD OPTION DELETE HEAD, etc.):
```php
$request->isMethod('GET'); 
```

* Get the value of the parameter `name`, there is no return for `null`:
```php
$request->input('name');
```

* Get the value of the parameter `name`, there is no return `'cabalphp'`:
```php
$request->input('name', 'cabalphp');
```


* Get all the parameters except `email` and `password`, you can pass the array to the first parameter:
```php
$request->except(['email','password']); 
```

* Get all parameters except `email` and `password`, you can pass multiple parameters:
```php
$request->except(['email','password']); 
```

* To get the uploaded file, you will get a `Zend\Diactoros\UploadedFile` object that implements the `Psr\Http\Message\UploadedFileInterface` interface:
```php
$request->file('file');  
```
* Determine if the parameter exists (isset), does not include the uploaded file:
```php
$request->has($name);
```

* Determine if the parameter is not empty (!empty || strlen > 0):
```php
$request->filled($name);
```


## Return response

CabalPHP accepts the following data as the controller return value:

1. An object that implements the `Psr\Http\Message\ResponseInterface` interface

```php
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Request;

$route->get('/', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    $response = new Response();
    // Must be reassigned, PSR-7 specifies that each modification returns a new object.
    $response = $response
        ->withStatus(500)
        ->withHeader('Version', 'alpha');
    $response->getBody()
        ->write('hello world');
    return $response;
});
```

The full HTTP response from the browser:

    HTTP/1.1 500 Internal Server Error
    Version: alpha
    Server: swoole-http-server
    Connection: keep-alive
    Content-Type: text/html
    Date: Thu, 12 Apr 2018 16:27:02 GMT
    Content-Length: 11

    hello world

1. Array, `stdClass` or object that implements `\JsonSerializable` - ** output string after `json_encode`**

```php
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$route->get('/', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return ['code' => 0, 'msg' => 'hello world'];
});
```

1. Object with `render` method - ** output string returned by render**

```php
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$route->get('/', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return ['code' => 0, 'msg' => 'hello world'];
});
```

1. String or number - ** Output string or number**

```php
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$route->get('/', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return 'hello world';
});
```