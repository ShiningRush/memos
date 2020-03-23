# CORS(Cross-Origin resource sharing) 笔记
CORS是一种为了解决跨域请求而诞生的规范，详细规范参见 [MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Access_control_CORS)

这里只介绍下一些需要注意的点：
- 跨域问题只存在于`客户端有安全策略限制的情况`，典型的如：浏览器，此时安全策略会阻止你进行跨域访问。如果是自己编写的程序，没有安全策略的限制，则不需要考虑跨域，所以`CORS`通常是前端考虑的问题。
- CORS有`简单请求`和`需预检的请求`区分，只有`需预检的请求`才会发起`OPTIONS`，两者的区分参考上面的MDN。
- 如果需要对凭据进行操作时，比如 携带了`Cookie`，此时需要设置`Access-Control-Allow-Credentials: true`，否则请求将会被浏览器拒绝。
- 在`Access-Control-Allow-Credentials: true`时，无法设置字段为通配符`*`。其他情况下任意字段都可以设置为通配符。
- Access-Control-Max-Age各个浏览器的最大时长不一样，
  - Firefox caps this at 24 hours (86400 seconds).
  - Chromium (prior to v76) caps at 10 minutes (600 seconds).
  - Chromium (starting in v76) caps at 2 hours (7200 seconds).
  - Chromium also specifies a default value of 5 seconds.
  - A value of -1 will disable caching, requiring a preflight OPTIONS check for all calls.