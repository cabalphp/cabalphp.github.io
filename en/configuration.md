# Configuration
All CabalPHP configuration files are stored in the conf directory, and the configuration files are in php format.

## Supported configuration items

### cabal.php
```php
return [
    // Whether to enable debugging
    'debug' => false,

    // The listening host defaults to `127.0.0.1`
    'host' => '127.0.0.1',

    // The listening port defaults to `9501`
    'port' => '9501',

    // See the swoole documentation for details on the mode of running swoole_server
    'mode' => '3',

    // The routing file configuration defaults to a file usr/routes.php, you can configure one or more according to your needs.
    'routes' => [
        'usr/routes1.php',
        'usr/routes2.php',
        'usr/routes3.php',
    ],

    // The configuration under the swoole block is the same as the configuration options written by all the swoole and the same name as the swoole configuration item.
    'swoole' => [
        / / Set the number of worker processes started.
        'worker_num' => 4,
    ],
];
```
> Related reference documents 
[swoole run mode documentation](https://wiki.swoole.com/wiki/page/14.html),
[swoole configuration options document](https://wiki.swoole.com/wiki/page/274.html)

## Environment Configuration

Put the corresponding configuration file under `conf/environment name/`, and the system will read the configuration file under the environment name directory first.

For example, add the `conf/dev/cabal.php` file. The contents of the file are as follows:

``` php
return [
    'port' => '8080',
];
```

run:
```bash
./bin/cabal -e dev start
```
The service will start at http://127.0.0.1:8080/.
