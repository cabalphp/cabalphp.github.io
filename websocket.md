# Websocket

## 简介
CabalPHP 默认支持websocket

只需要在routes中添加路由即可：

```php
// $route->ws('/chat', '类@前缀');
$route->ws('/chat', 'WebsocketController@on');
```

注册后当请求 `ws://host:port/chat` 会触发以下事件

* `HandShake(\Server $server, Request $request, $vars = [])` _非必选_
    - 刚开始连接时握手事件，可以增加逻辑判断，拒绝非法请求。
* `Open(\Server $server, Request $request)` _非必选_
    - 连接成功的打开事件，可以发送欢迎消息或初始化消息等。
3. `Message(\Server $server, Frame $frame, $vars = [])` **必选**
    - 接受到消息的时候触发的事件
* `Close(\Server $server, $fd, $reactorId)` _非必选_
    - 连接断开触发的事件，清理连接存储数据等。

对应到 `WebsocketController@on` 则是：
1. `WebsocketController@onHandShake`
2. `WebsocketController@onOpen`
3. `WebsocketController@onMessage`
4. `WebsocketController@onClose`

## fdSession
fdSession 是一个可以用来存储连接相关信息的缓存对象，数据存储在 worker 进程中，会随着 worker 销毁释放。

在 `HandShake` 和 `Open` 事件中可以用 `$request->fdSession()` 获得

在 `onMessage` 事件中可以用 `$frame->fdSession()` 获得

使用方法和 [session](/session.md) 类似。

?> `HandShake` 事件中可以正常使用 `$request->session()`，而在 `Open` 事件中可以读取 `$request->session()`。


## 聊天室示例

一个简单的聊天室：

?> 复杂业务可以在 `Message` 事件中使用 Cabal-Route 转发请求哦！

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
        $onlines = $server->onlines->add();

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
                    'systemMsg' => '昵称必须是2至12个字！',
                ]));
            } else {
                $fdSession['nickname'] = $nickname;
                $server->push($frame->fd, json_encode([
                    'systemMsg' => "昵称修改为 " . $nickname . " 成功！",
                ]));
            }
            return;
        } elseif (strlen($data) >= 5 && strtolower(substr($data, 0, 5)) == '/join') {
            $onlines = $server->onlines->get();
            $server->push($frame->fd, json_encode([
                'systemMsg' => "欢迎你加入聊天室！",
            ]));
            foreach ($server->connections as $fd) {
                $connectionInfo = $server->connection_info($fd);
                if (isset($connectionInfo['websocket_status']) && $connectionInfo['websocket_status'] == WEBSOCKET_STATUS_FRAME) {
                    $server->push($fd, json_encode([
                        'onlineNums' => $onlines,
                    ]));
                }
            }
            return;
        } elseif (strlen($data) < 1) {
            // $server->push($frame->fd, json_encode([
            //     'systemMsg' => "内容不能为空哦！",
            // ]));
            return;
        }

        $nickname = isset($fdSession['nickname']) ? $fdSession['nickname'] : "游客" . $frame->fd;
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
        $onlines = $server->onlines->sub();
        foreach ($server->connections as $fd) {
            $connectionInfo = $server->connection_info($fd);
            if (isset($connectionInfo['websocket_status']) && $connectionInfo['websocket_status'] == WEBSOCKET_STATUS_FRAME) {
                $server->push($fd, json_encode([
                    'onlineNums' => $onlines,
                ]));
            }
        }
    }

}
```


聊天室客户端：
```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>Websocket</title>
    <script>
        var ws = new WebSocket('ws://' + location.host + '/ws/chat');
        ws.onmessage = function (event) {
            var data = event.data;
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
            在线人数：
            <span id="online-nums"></span>
        </div>
    </div>
</body>

</html>
```