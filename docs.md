# 接口文档生成

CabalPHP 支持接口文档自动生成。  

编写好相关配置和文档注释后浏览器访问 `http://127.0.0.1:9501/__docs` 即可查看相关文档，注意检查自己的监听端口和IP。

点击[这里访问示例文档](http://demo.cabalphp.com/__docs#/)

?> 接口文档地址只能在debug环境（`cabal.debug`配置为true）下访问。

## 配置

文档相关配置在 `conf/cabal.php`
```php
    // ... 
    'document' => [
        // 是否启用文档，默认为 true
        // 'enabled' => true,  
        // 使用 知乎的 unpkg cdn，默认为 unpkg.com 没有国内节点，速度较慢。知乎的为国内节点，但是并不是官方公开的源，目前可外链，稳定性未知
        'cdn' => 'unpkg.zhimg.com',
        // 文档页面的项目名称
        'name' => 'CabalPHP',
    ],
    // ...
```

## 使用方法
系统会自动根据你的路由配置，解析控制器方法的**注释**，自动生成生成，**文档更新同样需要`reload`或者`restart`服务器**。

如果控制器继承自 `Cabal\Core\Base\FilterController` 系统会读取接口参数约束配置生成文档（接口参数的“约束”列）。  
详情可查看 [路由 & 控制器](/route_controller.md?id=过滤控制器api控制器) 文档。  

以下代码会生成一个[像这样的文档](http://demo.cabalphp.com/__docs#/%E7%94%A8%E6%88%B7 ':ignore')。

```php

class UserController extends FilterController
{
    public function rules()
    {
        return [
            'get' => [
                'id' => ['required', 'integer'],
                // 'email' => ['required', 'email', ['lengthMin', 4]],
            ],
        ];
    }

    /**
     * 获取用户
     * @apiModule 用户
     * @apiDescription 获取用户接口
     * - 支持换行
     * - 支持markdown
     * @apiParam id string 用户ID
     * @apiSuccess int code 返回码，0表示成功
     * @apiSuccess string msg 提示信息
     * @apiSuccess object data 提示信息
     * @apiSuccess object data.user 用户
     * @apiSuccess int data.user.id 用户ID
     * @apiSuccess int data.user.username 用户名
     * @apiSuccess int data.user.createdAt 创建时间戳
     * @apiSuccessExample json 创建成果 {
     *     "code":0, 
     *     "message":"",
     *     "data":{
     *         "user": {
     *             "id": 1,
     *             "username": "CabalPHP",
     *             "createdAt": 1530374400,
     *         }
     *     }
     * }
     * @apiError int code 错误码
     * @apiError string msg 错误信息
     * @apiErrorExample json Example {
     *     "code": 1,
     *     "message": "用户ID不存在"
     * } 
     * @apiErrorExample json Example2 {
     *     "code": 1,
     *     "message": "Id 只能是整数"
     * } 
     */
    public function get(\Server $server, Request $request, $vars = [])
    {
        $id = $request->input('id');
        if ($id < 10) {
            return [
                'code' => 0,
                'message' => '',
                'data' => [
                    'user' => [
                        'id' => $request->input('id'),
                        'username' => 'CabalPHP',
                        'createdAt' => 1530374400,
                    ],
                ],
            ];
        } else {
            return [
                'code' => 0,
                'message' => '用户ID不存在',
            ];
        }
    }
}
```

## 支持的语法

* @apiDescription 接口描述  可以换行，支持markdown
* @apiModule 模块名称  不能换行
* @apiIgnore 默认为不忽略，如果接口没有有注释但又不想展示文档时需要指定忽略该接口
* @apiSuccess 成功时候返回的字段
* @apiError 错误时候返回的字段
* @apiSuccessExample 成功返回示例
* @apiErrorExample 错误返回示例

```php
    /**
     * 接口名称
     * @apiDescription 接口描述 
     * 可以换行支持markdown
     * @apiModule 模块名称
     * @apiIgnore 1
     * @apiSuccess 字段类型 字段1 字段说明
     * @apiSuccess 字段类型 字段2 字段说明
     * @apiError 字段类型 字段1 字段说明
     * @apiError 字段类型 字段2 字段说明
     * @apiSuccessExample 类型 示例名称 示例内容
     * @apiErrorExample 类型 示例名称 示例内容
     */
```
