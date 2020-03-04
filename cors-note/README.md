# CORS(Cross-Origin resource sharing) 笔记
CORS是一种为了解决跨域请求而诞生的规范，详细规范参见 [MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Access_control_CORS)

这里只介绍下一些需要注意的点：
- 跨域问题只存在于`客户端有安全策略限制的情况`，典型的如：浏览器，此时安全策略会阻止你进行跨域访问。如果是自己编写的程序，没有安全策略的限制，则不需要考虑跨域，所以`CORS`通常是前端考虑的问题。
- CORS有`简单请求`和`需预检的请求`区分，只有`需预检的请求`才会发起`OPTIONS`，两者的区分参考上面的MDN。
- 如果需要对凭据进行操作时，比如 携带了`Cookie`，此时需要设置`Access-Control-Allow-Credentials: true`，否则请求将会被浏览器拒绝。
- 在`Access-Control-Allow-Credentials: true`时，无法设置`Access-Control-Allow-Origin: *`，必须设置为对应的域名。
- `Access-Control-Allow-Headers` 不允许设置为通配符 `*`，`Access-Control-Request-Method` 可以使用。