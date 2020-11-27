# go语言笔记
这里记录一些与 go 相关的点

## GODBUEG
可以通过环境`GODEBUG` 来输出 go 程序的相关信息，可选命令如下：
- `allocfreetrace`
- `clobberfree`
- `cgocheck`
- `efence`
- `gccheckmark`
- `gcpacertrace`
- `gcshrinkstackoff`
- `gctrace`
- `madvdontneed`
- `memprofilerate`
- `invalidptr`
- `sbrk`
- `scavenge`
- `scheddetail`
- `schedtrace`
- `tracebackancestors`
- `asyncpreemptoff`

完整命令参考 [这里](https://golang.org/pkg/runtime/)
值得一提得是，可以通过`name=val,name=val`来启用多个命令，如：
- ``

## http库的 ServeHttp 不能修改 request 的内容
很有意思的一点，在 `ServeHttp` 代码注释中写着
> Except for reading the body, handlers should not modify the
> provided Request.

稍微调查了下原因，是因为大量的现存代码会受到影响，所以在 `http.StripPrefix` 函数中，对 `Request` 进行了深拷贝。
```go
func StripPrefix(prefix string, h Handler) Handler {
	if prefix == "" {
		return h
	}
	return HandlerFunc(func(w ResponseWriter, r *Request) {
		if p := strings.TrimPrefix(r.URL.Path, prefix); len(p) < len(r.URL.Path) {
			r2 := new(Request)
			*r2 = *r
			r2.URL = new(url.URL)
			*r2.URL = *r.URL
			r2.URL.Path = p
			h.ServeHTTP(w, r2)
		} else {
			NotFound(w, r)
		}
	})
}
```

参考资料: [net/http: allow handlers to modify the http.Request](https://github.com/golang/go/issues/27277), [stack-overflow](https://stackoverflow.com/questions/13255907/in-go-http-handlers-why-is-the-responsewriter-a-value-but-the-request-a-pointer?rq=1)