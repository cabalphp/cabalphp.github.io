## CabalPHP


!> **The English version of the document uses Google Translate**

CabalPHP is a lightweight, efficient, fully asynchronous open source framework based on Swoole.


?> The author has been used in the production environment,Tencent Cloud two 4H8G (CabalPHP + Redis two services) support the daily active 3000W + PV statistical business, relying on the Task process asynchronously to write statistical data into Tencent Cloud MySQL. 

!> The framework concurrent scenario has been verified and the complex business scenario has not been verified.   
   At least we found bugs in the Swoole MySQL coroutine request scenario that were not found by other frameworks. ^_^


## Highlights

* Fully asynchronous single machine ultra high performance, easy distributed deployment
* Support HTTP, TCP, websocket and other protocols
* ** Perfect database engine, simple and efficient** (other swoole frameworks are almost no oh)
* Easy to learn, efficient development, simple and efficient database engine
* **Automatically generate API interface documentation**
* Complete code hints using IDE (Sublime Text/VSCode/PhpStorm, etc.)


## Applicable scene

* RPC service development for microservice architecture
* RESTful API interface development
* Instant messaging server development
* Traditional web site, server-side rendering SEO friendly

## Performance and stress testing


surroundings: 

* Tencent Cloud Container Service
* Mirror: swoole image based on php:7.1-alpine
* 1cores
* 256MiB - 512MiB
* php 7.1.12


    # ab -c 2000 -n 10000 http://172.16.1.79:9501/
    This is ApacheBench, Version 2.3 <$Revision: 1430300 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/

    Benchmarking 172.16.1.79 (be patient)
    Completed 1000 requests
    Completed 2000 requests
    Completed 3000 requests
    Completed 4000 requests
    Completed 5000 requests
    Completed 6000 requests
    Completed 7000 requests
    Completed 8000 requests
    Completed 9000 requests
    Completed 10000 requests
    Finished 10000 requests


    Server Software:        swoole-http-server
    Server Hostname:        172.16.1.79
    Server Port:            9501

    Document Path:          /
    Document Length:        284 bytes

    Concurrency Level:      2000
    Time taken for tests:   1.658 seconds
    Complete requests:      10000
    Failed requests:        3
    (Connect: 0, Receive: 0, Length: 3, Exceptions: 0)
    Write errors:           0
    Total transferred:      4330003 bytes
    HTML transferred:       2840003 bytes
    Requests per second:    6031.43 [#/sec] (mean)
    Time per request:       331.596 [ms] (mean)
    Time per request:       0.166 [ms] (mean, across all concurrent requests)
    Transfer rate:          2550.40 [Kbytes/sec] received

    Connection Times (ms)
                min  mean[+/-sd] median   max
    Connect:        0   37 154.4      2    1005
    Processing:    27  252  68.8    260     547
    Waiting:        0  250  69.2    259     546
    Total:         79  289 165.9    267    1369

    Percentage of the requests served within a certain time (ms)
    50% 267
    66% 284
    75% 303
    80% 314
    90% 347
    95% 365
    98% 1252
    99% 1279
    100%   1369 (longest request)

## Example

* [DEMO](http://demo.cabalphp.com/)
* [DEMO-Chat](http://119.28.136.181:9501/chat) 

## Donate

Donate some excellent code first!