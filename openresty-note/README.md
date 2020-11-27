# Openresty 笔记
## 简介
Openresty 是一个国人将LuaJIT嵌入Nginx进程进而可以使用Nginx来进行开发高性能的Web框架。
入门的简介可以参考这个文档，[OpenResty 不完全指南](https://juejin.im/entry/5ba3abd65188255c8a05f69c)

## 最佳实践
- 很多 lua 的内置函数都是全局变量，把它注册到本地来使用，性能会更好。
- 注意 Openresty 当中请求域名时会使用 Nginx 配置的 Dns 服务器，搜索 `resolver` 了解更多细节（Nginx 实现了一套内置的 DNS 解析）
- Openresty 中默认不读取 body ，可以通过以下方式打开
```
http {
    server {
        listen    80;

        # 默认读取 body
        lua_need_request_body on;

        location /test {
            content_by_lua_block {
                local data = ngx.req.get_body_data()
                ngx.say("hello ", data)
            }
        }
    }
}
```
或者局部开启
```
ngx.req.read_body()
```
- Openresty 有时 `ngx.req.get_body_data()` 读取不到数据时因为已经被转储到文件了，还需要从 `ngx.req.get_body_file` 中读取
- Nginx 有两个比较关键的参数 [client_body_buffer_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_buffer_size) 和 [client_max_body_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size) ，前者控制缓冲区大小，大于这个部分的请求体会被转储为临时文件（文档上说明为部分或全部，但目前观测到的情况一般都是全部转储）；后者控制能接受的最大请求体，大于会被拒绝( 413 Request Entity Too Large)