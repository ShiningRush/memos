# Wrk 用法
## Wrk是什么
wrk是一个开源的http的压测工具，它封装了很多开源项目的，比如`redis`的`ae`( *一个事件循环的非阻塞网络库，底层封装了 epoll 和 kqueue*) 和 `nginx` 的 `http-parser`。基于这些优秀的开源项目，所以它的性能相当高。不过也因为它用了`epoll`和`kqueue`的原因，所以目前只支持`linux`平台。
同时还集成了`LuaJIT`，所以可以自己写Lua脚本，放在 `/scripts` 目录下。[点击这里](https://github.com/wg/wrk) 访问它的 Github。

## 安装


## 基础用法
```bash
wrk -t12 -c400 -d30s http://127.0.0.1:8080/index.html
```

这个命令代表起 `12` 个线程来保持 `400`个 http连接，持续`30`秒。
输出如下：
```bash
Running 30s test @ http://127.0.0.1:8080/index.html
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   635.91us    0.89ms  12.92ms   93.69%
    Req/Sec    56.20k     8.07k   62.00k    86.54%
  22464657 requests in 30.00s, 17.76GB read
Requests/sec: 748868.53
Transfer/sec:    606.33MB
```

## 参数解释
```bash
-c, --connections: 要保持的连接总数，每个线程要处理链接数 = 连接总数/线程数

-d, --duration:    测试持续事件, 如 2s, 2m, 2h

-t, --threads:     总线程数

-s, --script:      lua脚本, 参考上面的链接

-H, --header:      要追加的http header e.g. "User-Agent: wrk"

    --latency:     统计详细的延迟

    --timeout:     如果一个请求在该时间内没有返回，则记录一个超时
```

## 使用技巧
运行wrk的计算机必须具有足够数量的临时端口(Port)，并且关闭的端口应该快速回收。为了处理初始连接突发，服务器(listen(2))[http://man7.org/linux/man-pages/man2/listen.2.html]的backlog应该大于正在测试的并发连接的数量。
(*这里稍微解释一下, listen 指linux的系统函数, 它的第二个参数 backlog 指定了能够服务的客户端最大数量，如果超过这个数量的请求都会被拒绝掉。 *)
仅更改HTTP Mehod，Path，Header 或 Body 的不会对性能产生影响。每个请求的操作（特别是构建新的HTTP请求）以及使用response（）必然会减少可以生成的负载量。