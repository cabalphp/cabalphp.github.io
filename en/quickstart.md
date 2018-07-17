# Quick Start


## Installation

### composer quick install

Domestic mirroring is recommended

```bash
composer create-project cabalphp/cabal-skeleton
```
### Manual installation

```bash
git clone git@github.com: cabalphp / skeleton.git
cd skeleton
composer install
```

## Run

```bash
./bin/cabal start
```

?> Support for incoming parameters `-e runtime environment` such as: `./bin/cabal -e dev start` will run in dev environment, the default is prod environment.

?> The listening port and IP can be found in the [Configuration chapter] of the documentation (https://github.com/QingWei-Li/docsify-cli).

After running, visit http://127.0.0.1:9501/ to see the following page.

![](/_media/home.png)

## Automatic hot update in Mac development environment

```bash
./bin/cabal-listen
```

After the file is saved, it will be automatically reloaded.


## Folder structure

* `bin` executable file storage directory
* `conf` configuration file storage directory
* `lib` third-party library folder, if the third-party library can not be installed with composer, please put it here.
* `test` directory contains automated test files
* `usr` Your project's business code folder contains: **routes, controllers, models, domain logic code**, etc.
* `var` resource files and storage files, etc.
* `vendor` Composer dependency package storage directory
