# 鉴权相关
## OAuth2.0
OAuth2.0 协议是针对授权流程的标准协议，不包括验证，OIDC 是在 OAuth2.0 之上进行的补充，包含了用户身份信息。
有关它的详细内容在 [RFC6749] https://tools.ietf.org/html/rfc6749，同时还有针对撤回Token和自省的 [RFC7009](https://tools.ietf.org/html/rfc7009)、[RFC7662](https://tools.ietf.org/html/rfc7662)。
撤回很容易理解，自省( introspection )指的是验证 token 有效性。
以及为了安全而生的 OAuth2.0 PKCE([RFC7636])。

这里简单介绍下 OAuth2.0 定义的四种模式：
- AuthorizationCode Grant: 授权码模式是最常见也最安全的一种模式，简单来说，接入方( 或者叫应用 ) 通过凭据换取授权码，再通过授权码换取 Token，但是过程中有可能被中间人劫持，所以有了 `PKCE` 来拓展该模式，保证它的安全
- Implict Grant: 隐式模式是授权码模式的简化，去除授权码而直接返回 Token，但是不返回 RefreshToken，这个模式同样也是不安全的
- ResourceOwnerPasswordCredentials: 资源拥有者密钥模式即接入方使用用户本身的密钥来换取凭据，这个一定要接入方是可信的，比如用户的桌面。
- Client Credentials: 这个是接入方以自己的密钥登录的场景。

关于各个模式的详细流程可以查看原生文档，也可以看下 DigitalOcean 的教程，[点击](https://www.digitalocean.com/community/tutorials/an-introduction-to-oauth-2)。
另外有关于 OAuth2.0 除了 PKCE 的授权码模式外都不安全的文章，[查看](https://www.ory.sh/hydra/docs/limitations#resource-owner-password-credentials-grant-type-rocp/)
文章提到了 ROPC 模式是 OAuth为了从 1.0 升到 2.0 但是为了兼容某些 IETF 联盟的大型传统公司而做出的让步， IETF 和 一些熟悉 OAuth 的人都不推荐使用这种模式，这种模式可以用于几种少见的常见：
- 遗留应用向 OAuth 转型
- 无浏览器设备，不过这个部分目前 OAuth 正在起草一个新的流程来补全

关于现在应用的 OAuth 实践，[点击这里](https://www.ory.sh/oauth2-for-mobile-app-spa-browser/)