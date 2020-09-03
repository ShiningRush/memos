# Prometheus
## Prometheus远程存储优化

Prometheus 以每两个小时为一个块，存储到磁盘中，内存保存近两个小时的内容，同时也会写 `WAL(write-ahead-log)`，预写日志文件wal以128MB的段存储在目录中。这些文件包含尚未压缩的原始数据，因此它们比常规的块文件要大。Prometheus将至少保留3个预写日志文件，但是高流量服务器可能会看到三个以上的WAL文件，因为它需要保留至少两个小时的原始数据。

这些块会在后台被压缩成更大的块以节省磁盘，最大长度取决于 `storage.tsdb.max-block-duration` 参数的设置，默认为保留时间的 `10%`。
一般来说 `storage.tsdb.max-block-duration` = `storage.tsdb.min-block-duration` = `2h` 就相当于禁用了压缩功能，
但是别让它们低于 `2h`，否则有以下的问题：
- 落盘过于频繁，这会很大程度影响 `Promethues` 的吞吐量。
- 由于 `WAL` 至少保留两个小时，所以这部分的内存是没办法释放的。

参考[Remote write tuning](https://prometheus.io/docs/practices/remote_write/)

## rate vs irate
两者的决定性差别在于:
- rate 使用整个时间区间所有点计算出平均变化速率，它会削平峰值
- irate 使用时间区间内最后的两个数据点作为变化速率

从它们两者的计算公式我们可以得到以下推论：
- 当选择的计算区间内仅仅包含两个数据点时，rate 和 irate 没有区别
- 我们使用 rate 来查看某个数据在较长一段时间内的变化趋势，它会消除一些细节防止影响趋势的展示
- 使用 irate 来查看某个数据在一段时间内的细小抖动和完整的变化。
- 使用 rate 时尽量选择较长的时间，而 irate 则反之（太长会丢失很多变化）

## relabel_config vs metric_relabel_configs
`relabel_config` 发生在 `metric_relabel_configs`，通常用于挑选 target 