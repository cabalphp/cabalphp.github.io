# View

The template engine for CabalPHP is [league/plates](http://platesphp.com). For related syntax, please refer to the documentation for plates.

## Get the template engine

To use plates, first modify `usr/boot.php` and undo the `use Cabal\Core\Http\Server\HasPlates` in the `Boot` class.

```php
Class Boot extends Cabal\Core\Application\Boot
{
    //...
    Use Cabal\Core\Http\Server\HasPlates;
    //...
}
```
Then in the controller can get the template engine with `$server->plates()`?:

```php
$route->get('/', function (Server $server, Request $request, $vars = []) {
    $response = new Response();
    $response->getBody()
        ->write(
            $server->plates()
                ->render('home')
        );
    Return $response;
});
```
You can also use the template engine you are used to.

!> Use plates to avoid io blockage and extend performance. Other template engines may need to be compiled, and be aware that there will be unexpected blocking.

## Using the template engine

Place the template file in the `var/template` folder, for example `var/template/home.php`:

```
$server->plates()
    ->render('home', ['version' => 'alpha']);
```

See the [plates documentation](http://platesphp.com/v3/templates/) for more documentation.