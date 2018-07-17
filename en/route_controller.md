# Route & Controller

The routing file defaults to `usr/routes.php`. You can also modify the configuration file according to your own situation and specify the routing file path.

The controller file defaults to the `usr/Controller` folder.


## Routing Configuration

Supported (request) methods:
```php
$route->map($method, $path, $handler); // method can be an array ['GET', 'POST`]
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

?> After the routing configuration is modified, you need to restart or reload the service.

The route handler can be a **anonymous function**:

```php
$route->get('/hello/{name}', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return "hello " . $vars['name'];
});
```
>  http://localhost:9501/hello/cabal 

It can also be a **function**:

```php
function hello (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars = []) {
    return "hello " . $vars['name'];
}
$route->get('/hello/{name}', 'hello');
```
It can also be a method** in a ** class, which can be _dynamic method _ or _ static method _.

The file `usr/Controller/HelloController.php` has the following contents:

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

Increase the routing configuration:

```php
$route->get('/hello2[/{name}]', 'Controller\\HelloController@getWorld'); 
$route->get('/hello3/{id:\d+}', 'Controller\\HelloController::staticWorld'); 
```

?> Path rules support regular configuration, etc. For details, please see [fastRoute documentation](https://github.com/nikic/FastRoute)

## Routing Group

```php
$route->group([
    'namespace' => 'Controller',
    'basePath' => '/group',
], function ($route) {
    $route->get('/hello2[/{name}]', 'HelloController@getWorld');
    $route->get('/hello3/{id:\d+}', 'HelloController::staticWorld');
}); 
```
or
```php
$route->group([
    'basePath' => '/group',
], function ($route) {
    $route->get('/hello2[/{name}]', 'HelloController@getWorld');
    $route->get('/hello3/{id:\d+}', 'HelloController::staticWorld');
})->namespace('Controller'); 
```

## Middleware

The middleware is similar to the middleware of other frameworks. It is not described too much. The following is a simple application. The situation of multiple middleware can be realized by itself.

* `$middlewareArgs` is the argument passed in when using middleware.
* `$next($server, $request, $vars);` For the next middleware or controller, do not call it if you want to interrupt.

```php
// Define middleware in the routes.php file 
$dispatcher->addMiddleware('before', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars, $next, $middlewareArgs = []) {
    // code..
    Return "before " . $middlewareArgs['name']; // Return directly, without executing the controller code, will continue to execute other middleware
});

$dispatcher->addMiddleware('after', function (\Cabal\Core\Http\Server $server, \Psr\Http\Message\ServerRequestInterface $request, $vars, $next, $middlewareArgs = []) {
    $response = $next($server, $request, $vars); // Call the controller first
    // code..
    Return "after: " . $response; // return, if there are other middleware, continue to execute other middleware

});

// use middleware
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

## Domain Name & Agreement
Routing supports filtering requests by protocol or domain name.
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


## Filter Controller / API Controller

The controller inherits `Cabal\Core\Base\FilterController` and implements the `rules` method, which returns the rules of the corresponding method to automatically constrain the request parameters.

!> The check will only verify the request parameters, and the matching parameters ($vars) will not participate in the check!

The validation class we use is: [vlucas/valitron](https://github.com/vlucas/valitron), please refer to the project documentation for supported configuration items and syntax.

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
            'fresh' => $ fresh,
        ];
    }
}
```
The request parameter does not pass the validation system will throw a `Cabal\Core\Exception\BadRequestException` exception, you can customize the exception handling in `routes.php` to determine your request response.
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



## Code hints

In order for `routes.php` to have code hints, please keep the following comments:

```php
/**
 * @var \Cabal\Core\Dispatcher $dispatcher
 */
/**
 * @var \Cabal\Route\RouteCollection $route
 */
```