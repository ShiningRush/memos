# http和tcp连接小记
## TCP 短连接与长连接
短连接与长连接的关键区分在于，`是否复用TCP连接`，短连接每次使用完毕都会释放连接，长连接则会将连接放入池中，等待下次使用。
所以实现长连接一般都会有几个关键参数：
- `最大连接数`: 其实就是连接池中保存连接数上限
- `过期时间`: 当请求数下降时，我们没有必要再维护这么多连接，所以我们需要给每条连接设置过期时间，当过期后及时从池中移除

在 `http1.0` 协议中，需要指定 `Connection: keep-alive` 来启用 TCP 长连接，`http1.1` 中已经成为默认值，无需指定，但是很多浏览器依旧会发送这个字段来兼容一些遗留的 web 服务。

*这里可能需要区分另一个用于 watch 结果的实现方式，我们知道一般有三种方式: 短轮询, 长轮询, websockt，长轮询当中会把请求 hold 住一段时间，让其也变成了 http 协议上的长连接，但是并不是我们 讨论的 tcp 协议上的长连接*

## 长连接消息的传输
传输编码：`Transfer-Encoding`， 内容编码: `Content-Encoding`
在长连接当中，由于连接不会断开，所以客户端无法知道消息是否已发送完毕，所以出现了 `Content-Length` 字段来告诉浏览器消息已传输完毕。但是很多情况下要计算出完整的响应体都是一件不容易的事情，为了计算出这个字段，我们需要把内容全部加载到内容中，这种实现非常不友好。所以出现了 `Transfer-Encoding`，一般为 `chunked` 代表分块传输。它不但解决动态内容长度的问题，同时还可以配合内容编码 (一般为 `gzip` or `deflate`) 进行变压缩边发送而无需预先知道压缩之前的内容大小。

### 分块格式
如果一个HTTP消息（包括客户端发送的请求消息或服务器返回的应答消息）的Transfer-Encoding消息头的值为chunked，那么，消息体由数量未定的块组成，并以最后一个大小为0的块为结束。
每一个非空的块都以该块包含数据的字节数（字节数以十六进制表示）开始，跟随一个CRLF （回车及换行），然后是数据本身，最后块CRLF结束。在一些实现中，块大小和CRLF之间填充有白空格（0x20）。
最后一块是单行，由块大小（0），一些可选的填充白空格，以及CRLF。最后一块不再包含任何数据，但是可以发送可选的尾部，包括消息头字段。
消息最后以CRLF结尾，
例子：
```
25
This is the data in the first chunk

1C
and this is the second one

3
con

8
sequence

0
```

更详细内容参考：[分块传输编码](https://zh.wikipedia.org/wiki/%E5%88%86%E5%9D%97%E4%BC%A0%E8%BE%93%E7%BC%96%E7%A0%81), [HTTP 协议中的 Transfer-Encoding](https://imququ.com/post/transfer-encoding-header-in-http.html)

很多语言都封装了完善的库来帮助我们完成 http 请求，导致我们很多时候都不知道 http 传输时的一些细节。实际上，这相当重要，会影响到 http 传输的性能。比如：
- 给出更大的 buffer 空间，你就会赢得更快的传输速度 (不超过带宽)，但是牺牲更多的空间。
- 如果 buffer 小于 chunk 的大小，那么会导致单个块传输效率更低甚至在某些库下会发生错误。

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