# http和tcp连接小记
## 短连接与长连接
短连接与长连接的关键区分在于，`是否复用TCP连接`，短连接每次使用完毕都会释放连接，长连接则会将连接放入池中，等待下次使用。
所以实现长连接一般都会有几个关键参数：
- `最大连接数`: 其实就是连接池中保存连接数上限
- `过期时间`: 当请求数下降时，我们没有必要再维护这么多连接，所以我们需要给每条连接设置过期时间，当过期后及时从池中移除



## TIME_WAIT 状态
`TIME_WAIT`状态是在四次挥手后，主动断开连接的一方会出现的状态，通常等待两个MSL时间 (*http规范为2分钟，但现在多数实现为30秒，所以一般等待一分钟*)会进入最后的`CLOSED`状态。
被动断开的一方会直接进入`CLOSED`状态。

`Nginx`中设置长连接可以有效避免 `TIME_WAIT` 产生；之前很奇怪为什么连接上游服务时，`Nginx`却会产生`TIME_WAIT`的连接，后来仔细想了想，一般场景中，无论调用方还是请求方，对连接都会有`Close`的调用，防止内存泄漏，所以谁先关闭都是有可能的。

`Nginx`设置长连接可以参考：[Nginx Upsteam](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive) 以及 [支持keep alive长连接](https://skyao.gitbooks.io/learning-nginx/content/documentation/keep_alive.html)

值得注意的是，`Nginx`的`keepalive_requests`要和`keepalive`一起使用才会有效果。

`keepalive_requests`指当长连接被使用多少次之后就会释放该连接，按照官方文档说法，周期性地释放连接是必要的，这样才可以释放每个连接所申请的内存。
`keepalive`指保持多少空闲连接在缓存中。

## Socket连接
可以由一个五元组来定义`[ 源IP, 源端口, 目的IP, 目的端口, 类型：TCP or UDP ]`，每个连接在 `Unix` 中会占用一个文件描述符(`FD`)

关于`TIME_WAIT`更详细的内容可以参考：[系统调优你所不知道的TIME_WAIT和CLOSE_WAIT](https://zhuanlan.zhihu.com/p/40013724)