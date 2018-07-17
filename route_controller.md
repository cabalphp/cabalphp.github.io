# 路由 & 控制器

路由文件默认在 `usr/routes.php`，你也可以根据自己的情况修改配置文件，指定路由文件路径。

控制器文件默认在 `usr/Controller`文件夹内。


## 路由配置

支持的（请求）方法：
```php
$route->map($method, $path, $handler);  // method 可以是数组 ['GET', 'POST`]
$route->get($path, $handler); 
$route->get($path, $handler); 
$route->post($path, $handler); 
$route->put($path, $handler); 
$route->patch($path, $handler); 
$route->delete($path, $handler); 
$route->head($path, $handler); 
$route->options($path, $handler); 
$route->any($path, $handler);   // GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS 
```

?> 路由配置修改后需要重启（restart）或者重新加载（reload）服务。

路由处理器可以是一个**匿名函数**：

```php
$route->get('/hello/{name}', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return "hello " . $vars['name'];
});
```
>  http://localhost:9501/hello/cabal 

也可以是一个**函数**：

```php
function hello (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return "hello " . $vars['name'];
}
$route->get('/hello/{name}', 'hello');
```
也可以是一个**类中的方法**，可以是_动态方法_也可以是_静态方法_。

文件 `usr/Controller/HelloController.php` 内容如下：

```php
namespace Controller;

use Psr\Http\Message\ServerRequestInterface;
use Cabal\Core\Http\Server;

class HelloController
{
    function getWorld(Server $server, ServerRequestInterface $request, $vars = [])
    {
        return "hello " . $vars['name'];
    }

    static public function staticWorld(Server $server, ServerRequestInterface $request, $vars = [])
    {
        return "hello " . $vars['id'];
    }
}
```

增加路由配置：

```php
$route->get('/hello2[/{name}]', 'Controller\\HelloController@getWorld'); 
$route->get('/hello3/{id:\d+}', 'Controller\\HelloController::staticWorld'); 
```

?> 路径规则支持正则等配置，具体可以查看 [fastRoute文档](https://github.com/nikic/FastRoute)

## 路由组

```php
$route->group([
    'namespace' => 'Controller',
    'basePath' => '/group',
], function ($route) {
    $route->get('/hello2[/{name}]', 'HelloController@getWorld');
    $route->get('/hello3/{id:\d+}', 'HelloController::staticWorld');
}); 
```
或者
```php
$route->group([
    'basePath' => '/group',
], function ($route) {
    $route->get('/hello2[/{name}]', 'HelloController@getWorld');
    $route->get('/hello3/{id:\d+}', 'HelloController::staticWorld');
})->namespace('Controller'); 
```

## 中间件

中间件和其他框架的中间件类似，不做太多描述，下面是简单的应用，多个中间件的情况可以自己实现后看下效果。

* `$middlewareArgs` 为使用中间件时传入的参数.
* `$next($server, $request, $vars);` 为下一个中间件或者控制器，要中断请不要调用它。

```php
// 在 routes.php 文件内 定义中间件 
$dispatcher->addMiddleware('before', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars, $next, $middlewareArgs = []) {
    // code..
    return "before " . $middlewareArgs['name']; // 直接返回，不执行控制器代码，会继续执行其他中间件
});

$dispatcher->addMiddleware('after', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars, $next, $middlewareArgs = []) {
    $response = $next($server, $request, $vars); // 先调用控制器
    // code..
    return "after: " . $response; // 返回，如果还有其他中间件会继续执行其他中间件

});

// 使用中间件
$route->group([
    'basePath' => '/group',
    'namespace' => 'Controller',
], function ($route) {
    $route->get('/hello2[/{name}]', 'HelloController@getWorld');
    $route->get('/hello3/{id:\d+}', 'HelloController::staticWorld');
})->middleware(['after']); 

$route->get('/hello2[/{name}]', 'Controller\\HelloController@getWorld')
    ->middleware(['before' => ['name' => 'middleware']]);
$route->get('/hello3/{id:\d+}', 'Controller\\HelloController::staticWorld')
    ->middleware(['before' => ['name' => 'middleware']]);

```

## 域名&协议
路由支持按协议或者域名过滤请求。
```php
$route->group([
    'basePath' => '/group',
], function ($route) {
    $route->get('/hello2[/{name}]', 'HelloController@getWorld');
    $route->get('/hello3/{id:\d+}', 'HelloController::staticWorld');
})->host('www.qq.com')
    ->scheme('https'); 

$route->get('/hello3/{id:\d+}', 'HelloController::staticWorld')
    ->host('www.qq.com') 
    ->scheme('https'); 
```


## 过滤控制器/API控制器

控制器继承 `Cabal\Core\Base\FilterController` 并实现 `rules` 方法，返回对应方法的规则即可自动约束请求参数。

!> 校验只会校验请求参数，路由匹配出来的参数（$vars）不参与校验！

我们使用的校验类为：[vlucas/valitron](https://github.com/vlucas/valitron)，支持的配置项和语法请参考该项目文档。

```php
<?php
namespace App\Controller;

use Cabal\Core\Http\Request;
use Cabal\Core\Base\FilterController;

class UserController extends FilterController
{
    public function rules()
    {
        return [
            'get' => [
                'id' => ['required', 'integer'],
                'email' => ['required', 'email', ['lengthMin', 4]],
            ],
        ];
    }

    public function get(\Server $server, Request $request, $vars = [])
    {
        return [
            'action' => __METHOD__,
            'input' => $request->all(),
            'vars' => $vars,
        ];
    }
}
```
请求参数没通过校验系统会抛出一个`Cabal\Core\Exception\BadRequestException`异常，你可以在`routes.php`中自定义异常处理来决定你的请求响应。
```php

use Cabal\Core\Exception\BadRequestException;

$dispatcher->registerExceptionHandler(function ($server, $ex, $chain, $request) {
    if ($ex instanceof BadRequestException) {
        return [
            'code' => 1,
            'msg' => $ex->getMessage(),
            'msgs' => $ex->getMessages(),
        ];
    }
    return [
        'code' => -1,
        'msg' => 'Internal Server Error',
    ];
});
```



## 代码提示

为了让 `routes.php` 有代码提示 请保留下面注释：

```php
/**
 * @var \Cabal\Core\Dispatcher $dispatcher
 */
/**
 * @var \Cabal\Route\RouteCollection $route
 */
```