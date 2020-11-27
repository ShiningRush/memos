# 网络分析

在 `linux` 上我们可以使用 `tcpdump` 来分析流量包，`wireshark` 分析包，`strace` 查看进程调用。
`fiddler` 用于分析 http 协议，`wireshark` 用于分析 tcp/udp 的网络封包

## https 包抓取
网络流量的这些工具为了能够解析 https 的包，通常都是自己签发证书，然后让系统信任自己证书，以作为中间人去转发、解析 https 流量。
如果仅仅只是为了代理 https 流量而不解析，可以使用 http 的隧道协议，使用 `CONNECT` method 去连接代理服务器，然后代理服务自动转发握手请求，相当于客户端直接与目标服务连接。