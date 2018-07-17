# 文档处理
CabalPHP 支持接口文档自动生成。  


?> 接口文档地址只有debug环境下访问。

## 配置

文档配置在 `conf/cabal.php` 内，
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

以下代码会生成一个[像这样的文档](/_media/docs.png ':ignore')。

```php

class UserController extends FilterController
{
    public function rules()
    {
        return [
            'post' => [
                'email' => ['required', 'email'],
                'username' => ['required', ['lengthMin', 4]],
                'password' => ['required', ['lengthMin', 8]],
            ],
        ];
    }

    /**
     * 创建用户
     * @apiModule 用户
     * @apiDescription 创建用户接口
     * - 支持换行
     * - 支持markdown
     * @apiParam email string 邮箱
     * @apiParam username string 用户名
     * @apiParam password string 密码
     * @apiSuccess int code 返回码，0表示成功
     * @apiSuccess string msg 提示信息
     * @apiSuccess object data 数据
     * @apiSuccess object data.user 用户
     * @apiSuccess int data.user.id 用户ID
     * @apiSuccess int data.user.createdAt 创建时间戳
     * @apiSuccessExample json 创建成果 {
     *     "code":0, 
     *     "message":"",
     *     "data":{
     *         "user": {
     *             "id": 1,
     *             "createdAt": 1530374400,
     *         }
     *     }
     * }
     * @apiError int code 错误码
     * @apiError string msg 错误信息
     * @apiErrorExample json Example {
     *      "code":1, 
     *      "message":"邮箱已经被使用"
     * }
     */
    public function post(\Server $server, Request $request, $vars = [])
    {
        // return ['id' => $request->input('id'), 'name' => $request->input('name')];
        return [$request->input('id'), $request->input('name')];
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
