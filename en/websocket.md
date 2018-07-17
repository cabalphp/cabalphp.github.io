# Websocket

## Introduction
CabalPHP supports websocket by default

Just add a route to the routes:

```php
// $route->ws('/chat', 'class@prefix');
$route->ws('/chat', 'WebsocketController@on');
```

The following event is triggered when requesting `ws://host:port/chat` after registration

* `HandShake(\Server $server, Request $request, $vars = [])` _ not required _
    - The handshake event at the beginning of the connection can increase the logical judgment and reject the illegal request.
* `Open(\Server $server, Request $request)` _ not required _
    - A successful open event can be sent to send a welcome message or an initialization message.
3. `Message(\Server $server, Frame $frame, $vars = [])` **Required**
    - Events triggered when a message is received
* `Close(\Server $server, $fd, $reactorId)` _ not required _
    - Connect disconnected triggered events, clean up connection storage data, etc.

Corresponding to `WebsocketController@on` is:
1. `WebsocketController @ onHandShake`
2. `WebsocketController@onOpen`
3. `WebsocketController@onMessage`
4. `WebsocketController@onClose`

## fdSession
fdSession is a cache object that can be used to store connection-related information. The data is stored in the worker process and is released as the worker destroys it.

In `HandShake` and `Open` events you can get it with `$request->fdSession()`

In `onMessage` event you can get it with `$frame->fdSession()`

The usage is similar to [session](/session.md).

?> ``request->session()` can be used normally in the `HandShake` event, and `$request->session()` can be read in the `Open` event.


## Chat Room Example

A simple chat room:

?> Complex services can use Cabal-Route to forward requests in the `Message` event!

```php
<?php
namespace App\Controller;

use Cabal\Core\Http\Request;
use Cabal\Core\Http\Frame;
use Cabal\Core\Http\Response;

class WebsocketController
{
    public function chat(\Server $server, Request $request, $var = [])
    {
        $response = new Response();
        $response->getBody()
            ->write(
                $server->plates()->render('chat')
            );
        return $response;
    }

    public function onHandShake(\Server $server, Request $request, $vars = [])
    {
        $session = $request->session();
        $session['test'] = date('Y-m-d H:i:s');

        $fdSession = $request->fdSession();
        $fdSession['test'] = date('Y-m-d H:i:s');
        $ onlines = $ server-> online-> add ();

    }

    public function onOpen(\Server $server, Request $request)
    {
    }
    public function onMessage(\Server $server, Frame $frame, $vars = [])
    {
        $fdSession = $frame->fdSession();
        $data = trim($frame->data);
        if (strlen($data) >= 6 && strtolower(substr($data, 0, 6)) == '/name ') {
            $nickname = substr($data, 6);
            if (mb_strlen($nickname, 'utf-8') > 12 || mb_strlen($nickname, 'utf-8') < 2) {
                $server->push($frame->fd, json_encode([
                    'systemMsg' => 'The nickname must be 2 to 12 words! ',
                ]));
            } else {
                $fdSession['nickname'] = $nickname;
                $server->push($frame->fd, json_encode([
                    'systemMsg' => "昵 is modified to ". $nickname . "Success!",
                ]));
            }
            return;
        } elseif (strlen($data) >= 5 && strtolower(substr($data, 0, 5)) == '/join') {
            $ online = $ server-> online-> get ();
            $server->push($frame->fd, json_encode([
                'systemMsg' => "Welcome to join the chat room!",
            ]));
            foreach ($server->connections as $fd) {
                $connectionInfo = $server->connection_info($fd);
                if (isset($connectionInfo['websocket_status']) && $connectionInfo['websocket_status'] == WEBSOCKET_STATUS_FRAME) {
                    $server->push($fd, json_encode([
                        'onlineNums' => $ online,
                    ]));
                }
            }
            return;
        } elseif (strlen($data) < 1) {
            // $server->push($frame->fd, json_encode([
            // 'systemMsg' => "Content cannot be empty!",
            // ]));
            return;
        }

        $nickname = isset($fdSession['nickname']) ? $fdSession['nickname'] : "Visitor" . $frame->fd;
        foreach ($server->connections as $fd) {
            $connectionInfo = $server->connection_info($fd);
            if (isset($connectionInfo['websocket_status']) && $connectionInfo['websocket_status'] == WEBSOCKET_STATUS_FRAME) {
                $server->push($fd, json_encode([
                    'nickname' => $nickname,
                    'datetime' => date('Y-m-d H:i:s'),
                    'msg' => $frame->data,
                ]));
            }
        }
    }

    public function onClose(\Server $server, $fd, $reactorId)
    {
        $ onlines = $ server-> online-> sub ();
        foreach ($server->connections as $fd) {
            $connectionInfo = $server->connection_info($fd);
            if (isset($connectionInfo['websocket_status']) && $connectionInfo['websocket_status'] == WEBSOCKET_STATUS_FRAME) {
                $server->push($fd, json_encode([
                    'onlineNums' => $ online,
                ]));
            }
        }
    }

}
```


Chat room client:
```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>Websocket</title>
    <script>
        var ws = new WebSocket ('ws: //' + location.host + '/ ws / chat');
        ws.onmessage = function (event) {
            was data = event.data;
            data = eval('(' + data + ')');
            if ('systemMsg' in data) {
                var line = document.createElement('div');
                line.className = 'sysMsg';
                line.innerHTML = data.systemMsg;
                document.getElementById('msg').appendChild(line);
            } else if ('onlineNums' in data) {
                document.getElementById('online-nums').innerHTML = data.onlineNums;
            } else {
                var line = document.createElement('div');
                line.innerHTML = '<span>[' + data.nickname + ']</span> ' + data.msg + ' <span class="datetime">' + data.datetime + '</span>';
                document.getElementById('msg').appendChild(line);
            }
        };
        ws.onopen = function(event) {
            ws.send('/join')
        }
        function send(e, input) {
            if (e.charCode == 13) {
                ws.send(input.value);
                input.value = '';
            }
        }
    </script>
    <style>
        .warp{width:400px}
        #msg{padding:10px;border:1px solid #eee;min-height:500px;font-size:14px;line-height:1.8;line-height:1.8}
        #msg span{color:#2b94ff}
        #msg .datetime{color:#ddd}
        #msg .sysMsg{color:#fe684c}
        .infos{font-size:14px;color:#777;padding:8px 13px;text-align:right}
        input{padding:8px 12px;font-size:14px;width:374px;border:1px solid #eee;border-top:none}
    </style>
</head>

<body>
    <div class="warp">
        <div id="msg"></div>
        <div>
            <input type="text" onkeypress="send(event,this)" placeholder="回车发送 /name 昵称 改名" />
        </div>
        <div class="infos">
            online users:
            <span id="online-nums"></span>
        </div>
    </div>
</body>

</html>
```