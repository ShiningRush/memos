# Vegeta( 贝吉塔 )

这是一个开源软件，类似 wrk ，但是是用 go 写的，功能更为强大，也更易用一些。

[Github 地址](https://github.com/tsenart/vegeta)

下面是命令列表：
```
Usage: vegeta [global flags] <command> [command flags]

global flags:
  -cpus int
    	Number of CPUs to use (defaults to the number of CPUs you have)
  -profile string
    	Enable profiling of [cpu, heap]
  -version
    	Print version and exit

attack command:
  -body string
    	Requests body file
  -cert string
    	TLS client PEM encoded certificate file
  -chunked
    	Send body with chunked transfer encoding
  -connections int
    	Max open idle connections per target host (default 10000)
  -duration duration
    	Duration of the test [0 = forever]
  -format string
    	Targets format [http, json] (default "http")
  -h2c
    	Send HTTP/2 requests without TLS encryption
  -header value
    	Request header
  -http2
    	Send HTTP/2 requests when supported by the server (default true)
  -insecure
    	Ignore invalid server TLS certificates
  -keepalive
    	Use persistent connections (default true)
  -key string
    	TLS client PEM encoded private key file
  -laddr value
    	Local IP address (default 0.0.0.0)
  -lazy
    	Read targets lazily
  -max-body value
    	Maximum number of bytes to capture from response bodies. [-1 = no limit] (default -1)
  -max-workers uint
    	Maximum number of workers (default 18446744073709551615)
  -name string
    	Attack name
  -output string
    	Output file (default "stdout")
  -proxy-header value
    	Proxy CONNECT header
  -rate value
    	Number of requests per time unit [0 = infinity] (default 50/1s)
  -redirects int
    	Number of redirects to follow. -1 will not follow but marks as success (default 10)
  -resolvers value
    	List of addresses (ip:port) to use for DNS resolution. Disables use of local system DNS. (comma separated list)
  -root-certs value
    	TLS root certificate files (comma separated list)
  -targets string
    	Targets file (default "stdin")
  -timeout duration
    	Requests timeout (default 30s)
  -unix-socket string
    	Connect over a unix socket. This overrides the host address in target URLs
  -workers uint
    	Initial number of workers (default 10)

encode command:
  -output string
    	Output file (default "stdout")
  -to string
    	Output encoding [csv, gob, json] (default "json")

plot command:
  -output string
    	Output file (default "stdout")
  -threshold int
    	Threshold of data points above which series are downsampled. (default 4000)
  -title string
    	Title and header of the resulting HTML page (default "Vegeta Plot")

report command:
  -buckets string
    	Histogram buckets, e.g.: "[0,1ms,10ms]"
  -every duration
    	Report interval
  -output string
    	Output file (default "stdout")
  -type string
    	Report type to generate [text, json, hist[buckets], hdrplot] (default "text")

examples:
  echo "GET http://localhost/" | vegeta attack -duration=5s | tee results.bin | vegeta report
  vegeta report -type=json results.bin > metrics.json
  cat results.bin | vegeta plot > plot.html
  cat results.bin | vegeta report -type="hist[0,100ms,200ms,300ms]"
```

 这里主要提一下 `-format=json` 时，可以使用类似以下的 json 文件作为请求源，这样动态能力会更强一些，在压测 TPS 时特别有用：
 ```json
{ "method":"GET", "url": "xxxx", "body":"base64(xxxxx)", "header": { "key": "value" } }
{ "method":"POST", "url": "xxxx", "body":"base64(xxxxx)", "header": { "key": "value" } }
 ```

如果没有特别的要求，一般压测 QPS使用 `-format=http`，这也是默认值。
```text
GET http://user:password@goku:9090/path/to
X-Account-ID: 8675309

DELETE http://goku:9090/path/to/remove
Confirmation-Token: 90215
Authorization: Token DEADBEEF
```