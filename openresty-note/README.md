# Openresty 笔记
## 简介
Openresty 是一个国人将LuaJIT嵌入Nginx进程进而可以使用Nginx来进行开发高性能的Web框架。
入门的简介可以参考这个文档，[OpenResty 不完全指南](https://juejin.im/entry/5ba3abd65188255c8a05f69c)

## 最佳实践
- 很多 lua 的内置函数都是全局变量，把它注册到本地来使用，性能会更好。
- 注意 Openresty 当中请求域名时会使用 Nginx 配置的 Dns 服务器，搜索 `resolver` 了解更多细节（Nginx 实现了一套内置的 DNS 解析）
