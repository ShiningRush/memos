# k8s 笔记

这里记录一些常用但容易忘记的内容。

## 存储相关
### ConfigMap 热更新
更新configmap后：
- 使用该configmap的环境变量和命令行参数不会触发更新。
- 使用该configmap挂载的数据卷会触发更新。
- 如果使用子路径方式挂载的数据卷，将不会触发更新。

### PV(PersistentVolume) 与 PVC(PersistentVolumeClaim)

类似 `Pod` 与 `Node` 的关系，每个 `PVC` 可以与一个 `PV` 绑定。它们之间需要满足以下条件：
- 请求大小相同
- `StorageClass` 相同


但是与 `Pod` 的不同处在于：一个 `PVC` 只能与 `PV` 一一对应（因为要求资源大小相等）。
使用 `PV` 我们让一个 `POD` 的存储得以持久化，通常来说我们都会配合 `StatefulSet` 来使用。当然，你完全可以通过 `PV` 让一个 `Deployment` 持有状态，但 `StatefulSet` 会更适合有状态的场景。
同时 `StatefulSet` 中还提供了 `VolumeClaimTemplates` 这样的字段来方便自动创建 `PVC`，配合 `动态PV` 可以轻松驾驭持久存储的体系。

一些 Tips:
- 预先创建 `PV` 再创建 `PVC` 绑定它们的这种方式被称为 `静态PV`，在 `1.12` 出现了 `StorageClass` 来完成自动创建 `PV` 的过程，被称为 `动态PV`。
- `StorageClass` 是一个 `CRD( 自定义资源 )`, 它包含了如何访问数据源的一些细节，如参数，类型等等，为 `动态PV` 提供了支撑。在之前，这些信息都保存在 `PV` 中。
- `StatefulSet` 删除时不会自动删除 `PVC`，需要用户手动删除，这是为了让用户能够恢复数据。其他资源则不会，如 `Deployment`。


## 杂项
- client-go 中提供了很多有用的库：workerqueue(包含限速和延迟队列，多对多且并发安全), leaderelection, resourcelock(类似分布式锁)
- ServiceAccount 已弃用，ServiceAccountName 是最新项
- 每个 ServiceAccount 创建时都会自动生成一个 ServiceAccoutSecret，并且挂载到使用了 ServiceAccount 的 Pod 中
- 可以使用以下命令查看容器中的网络
```
docker inspect -f {{.State.Pid}}    容器id   # 获取容器的pid
nsenter -n -t pid   # 进入容器网络空间
```
简写为
```
nsenter -n -t $(docker inspect -f {{.State.Pid}} dockerid)
```


## 网络模型
k8s 对网络提出了三个基本要求
- pods on a node can communicate with all pods on all nodes without NAT ( 节点上的 POD 不需要通过 NAT 就可以与其他任意节点的 POD 通信 )
- agents on a node (e.g. system daemons, kubelet) can communicate with all pods on that node (节点上的代理程序可以与该节点上的任意 POD 通信 )

下面的这个要求仅针对支持 `HostNetwork` 模式的平台，如 linux
- pods in the host network of a node can communicate with all pods on all nodes without NAT ( 节点上的 hostnetwork POD 不需要通过 NAT 就可以与其他任意节点的 POD 通信 )

## DNS解析
FQDN(Fully Qualified Domain Name) 代表完全限定域名，在进行域名解析时将不会在后面追加顶级域名，FQDN( Partially Qualified Domain Name ) 部分限定域名，可以根据场景在后方追加顶级域名。
最明显的区别在于 FQDN 后跟一个 `.`, 如 `www.baidu.com.`
- 解析域名时，遵从 `/etc/resolve.conf` 指定的参数, `nameserver` 指代下一级查询的 dns 服务器， `search` 指定在域名为 PQDN 时，尝试追加的基本域名
- k8s 在网络容器初始化时会根据 yaml 的内容来决定如何初始化 pod 的内容，参考 [Pod 与 Service 的 DNS](https://kubernetes.io/zh/docs/concepts/services-networking/dns-pod-service/)
- 在普通 linux 的 `resolve.conf` 配置 `search` 后，如果请求域名中没有 `.` 那么认为是主机名，优先追加 `search` 的域名去查找，最后才查找主机名，比如 `host`，如果含有点，且大于 `options.ndots:n` 当中配置的数量 `n`，则认为是 FQDN 优先查找自身 如 `host.name`，可以通过 `host -a `命令查看解析域名的过程