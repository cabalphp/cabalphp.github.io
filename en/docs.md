# API Document Generate

CabalPHP supports automatic generation of interface documents.  

After writing the relevant configuration and documentation comments, the browser can access the `http://127.0.0.1:9501/__docs` to view related documents, and check your own listening port and IP.

Click [here to access the sample document](http://demo.cabalphp.com/__docs#/)

?> The interface document address is only accessible under the debug environment (the `cabal.debug` is configured to true).

## Configuration

Document related configuration in `conf/cabal.php`
```php
    // ... 
    'document' => [
        // Whether to enable the document, the default is true
        // 'enabled' => true,  
        // Use the unpkg cdn, the default is unpkg.com There is no domestic node, the speed is slower. Known as a domestic node, but not an official open source, currently available outside the chain, stability is unknown
        'cdn' => 'unpkg.zhimg.com',
        // project name of the document page
        'name' => 'CabalPHP',
    ],
    // ...
```

## Instructions
The system will automatically parse the controller method's **notes** according to your routing configuration, automatically generate the generated, **document updates also require `reload` or `restart` server**.

If the controller inherits from the `Cabal\Core\Base\FilterController` system, it will read the interface parameter constraint configuration generation document (the "constraint" column of the interface parameter).  
See the [Routing & Controller](/route_controller.md?id=Filter Controller api Controller) documentation for details.  

The following code will generate a [document like this](http://demo.cabalphp.com/__docs#/%E7%94%A8%E6%88%B7 ':ignore').

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
     * Get users
     * @apiModule user
     * @apiDescription Get user interface
     * - Support for line breaks
     * - Support markdown
     * @apiParam id string user ID
     * @apiSuccess int code return code, 0 means success
     * @apiSuccess string msg prompt message
     * @apiSuccess object data prompt message
     * @apiSuccess object data.user user
     * @apiSuccess int data.user.id User ID
     * @apiSuccess int data.user.username username
     * @apiSuccess int data.user.createdAt Create timestamp
     * @apiSuccessExample json create results {
     *     "code":0, 
     *     "message":"",
     *     "data":{
     *         "user": {
     *             "id": 1,
     *             "username": "CabalPHP",
     *             "createdAt": 1530374400,
     * }
     * }
     * }
     * @apiError int code error code
     * @apiError string msg error message
     * @apiErrorExample json Example {
     *     "code": 1,
     * "message": "User ID does not exist"
     * } 
     * @apiErrorExample json Example2 {
     *     "code": 1,
     * "message": "Id can only be an integer"
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
                'message' => 'User ID does not exist',
            ];
        }
    }
}
```

## Supported syntax

* @apiDescription interface description can be wrapped, support markdown
* @apiModule module name cannot be wrapped
* @apiIgnore defaults to not ignore, if the interface does not have a comment but does not want to display the document, you need to specify to ignore the interface
* @apiSuccess field returned when successful
* @apiError field returned when error
* @apiSuccessExample returns the example successfully
* @apiErrorExample error return example

```php
    /**
     * Interface name
     * @apiDescription interface description 
     * Can be changed to support markdown
     * @apiModule module name
     * @apiIgnore 1
     * @apiSuccess Field Type Field 1 Field Description
     * @apiSuccess Field Type Field 2 Field Description
     * @apiError Field Type Field 1 Field Description
     * @apiError Field Type Field 2 Field Description
     * @apiSuccessExample type example name sample content
     * @apiErrorExample type example name example content
     */
```