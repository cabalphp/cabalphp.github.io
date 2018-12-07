# 请求 & 响应


CabalPHP 的请求（Request）和响应（Response）对象依赖 [zendframework/zend-diactoros](https://github.com/zendframework/zend-diactoros) 实现了 [PSR-7标准](http://www.php-fig.org/psr/psr-7/) [psr/http-message](https://github.com/php-fig/http-message)  中的 `Psr\Http\Message\ServerRequestInterface`和`Psr\Http\Message\ResponseInterface` 的全部接口，同时也扩展了自己的一些实用方法方便使用。


## 获取请求

你可以用PSR-7中的 `\Psr\Http\Message\ServerRequestInterface` 来获得请求对象：
```php
$route->get('/hello/{name}', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return "hello " . $vars['name'];
});
```

也可以用 `Cabal\Core\Http\Request` 来获得请求对象：
```php
use Cabal\Core\Http\Request;
use \Cabal\Core\Http\Server;

$route->get('/hello/{name}', function (Server $server, Request $request, $vars = []) {
    return "hello " . $vars['name'];
});
```

?> 无论哪种方式，你得到的都是一个 `Cabal\Core\Http\Request` 对象

?> 路由规则里匹配出来的的参数在 `$vars` 变量中。


## 获取输入参数

CabalPHP 会帮你将 GET 参数和 POST（请求体中的数据） 参数合并，优先使用 POST 中的参数。

* 获取所有数据：
```php
$request->all();
```

* 只获取 `username` 和 `password`，可以第一个参数传数组：
```php
$request->only(['username', 'password']);
```

* 只获取 `username` 和 `password`，可以传递多个参数：
```php
$request->only('username', 'password');  
```

* 判断是否是一个 ajax 请求（X-Requested-With=XMLHttpRequest）：
```php
$request->isXhr();
```

* 判断是否是指定的请求方法（GET HEAD OPTION DELETE HEAD等）：
```php
$request->isMethod('GET'); 
```

* 获取参数 `name` 的值，不存在返回 `null`：
```php
$request->input('name');
```

* 获取参数 `name` 的值，不存在返回 `'cabalphp'`：
```php
$request->input('name', 'cabalphp');
```


* 获取除了 `email` 和 `password` 外的其他所有参数，可以第一个参数传数组：
```php
$request->except(['email','password']); 
```

* 获取除了 `email` 和 `password` 外的其他所有参数，可以传递多个参数，也可以第一个参数传递数组：
```php
$request->except('email','password'); 
$request->except(['email','password']); 
```

* 获取上传的文件，你会得到一个实现了 `Psr\Http\Message\UploadedFileInterface` 接口的 `Zend\Diactoros\UploadedFile` 对象：
```php
$request->file('file');  
```
* 判断参数是否存在（isset），不包含上传的文件：
```php
$request->has($name);
```

* 判断参数是否不为空 （!empty || strlen > 0）：
```php
$request->filled($name);
```


## 返回响应

CabalPHP 接受以下数据作为控制器返回值：

1. 实现了 `Psr\Http\Message\ResponseInterface` 接口的对象

```php
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Response;
use Cabal\Core\Http\Request;

$route->get('/', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    $response = new Response();
    // 必须重新赋值，PSR-7规定每次修改都是返回新对象哦
    $response = $response
        ->withStatus(500)
        ->withHeader('Version', 'alpha');
    $response->getBody()
        ->write('hello world');
    return $response;
});
```

浏览器得到的完整HTTP响应：

    HTTP/1.1 500 Internal Server Error
    Version: alpha
    Server: swoole-http-server
    Connection: keep-alive
    Content-Type: text/html
    Date: Thu, 12 Apr 2018 16:27:02 GMT
    Content-Length: 11

    hello world

1. 数组、`stdClass`或实现了`\JsonSerializable`的对象 - **输出 `json_encode` 后的字符串**

```php
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$route->get('/', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return ['code' => 0, 'msg' => 'hello world'];
});
```

1. 有 `render` 方法的对象 - **输出 render 返回的字符串**

```php
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$route->get('/', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return ['code' => 0, 'msg' => 'hello world'];
});
```

1. 字符串或数字 - **输出字符串或数字**

```php
use Cabal\Core\Http\Server;
use Cabal\Core\Http\Request;

$route->get('/', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return 'hello world';
});
```
