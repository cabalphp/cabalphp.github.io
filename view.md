# 模板视图

CabalPHP的模板引擎是 [league/plates](http://platesphp.com)，相关语法请参考 plates 的文档。

## 获取模板引擎

要使用 plates 请先修改 `usr/boot.php`，取消 `Boot` 类中的 `use Cabal\Core\Http\Server\HasPlates` 注释：

```php
class Boot extends Cabal\Core\Application\Boot
{
    //...
    use Cabal\Core\Http\Server\HasPlates;
    //... 
}
```
然后在控制器中可以用 `$server->plates()` 获取到模板引擎：

```php
$route->get('/', function (Server $server, Request $request, $vars = []) {
    $response = new Response();
    $response->getBody()
        ->write(
            $server->plates()
                ->render('home')
        );
    return $response;
});
```
你也可以使用自己习惯的模板引擎。

!> 使用 plates 是为了避免产生io堵塞，延续性能。其他模板引擎可能需要编译，要注意会不会产生意外的阻塞。

## 使用模板引擎

请将模板文件放置在 `var/template` 文件夹中，例如 `var/template/home.php`：

```
$server->plates()
    ->render('home', ['version' => 'alpha']);
```

更多相关文档请查阅 [plates文档](http://platesphp.com/v3/templates/)。