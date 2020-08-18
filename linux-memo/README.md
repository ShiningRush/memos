# Linux 系统小计

## 修改环境变量
- 可以通过 `export var=value` 在当前控制台修改，不会永久生效
- 可以通过 以下文件 修改 ，添加 `export var=value`
```
============
/etc/profile
============
此文件为系统的每个用户设置环境信息,当用户第一次登录时,该文件被执行.
并从/etc/profile.d目录的配置文件中搜集shell的设置.

===========
/etc/bashrc
===========
为每一个运行bash shell的用户执行此文件.当bash shell被打开时,该文件被读取.

===============
~/.bash_profile
===============
每个用户都可使用该文件输入专用于自己使用的shell信息,当用户登录时,该
文件仅仅执行一次!默认情况下,他设置一些环境变量,执行用户的.bashrc文件.

=========
~/.bashrc
=========
该文件包含专用于你的bash shell的bash信息,当登录时以及每次打开新的shell时,该文件被读取.

==========
~/.profile
==========
在Debian中使用.profile文件代 替.bash_profile文件
.profile(由Bourne Shell和Korn Shell使用)和.login(由C Shell使用)两个文件是.bash_profile的同义词，目的是为了兼容其它Shell。在Debian中使用.profile文件代 替.bash_profile文件。

==============
~/.bash_logout
==============当每次退出系统(退出bash shell)时,执行该文件
```

## 常用命令
- 查找文件是否包含字符串
```
grep -rn "string" /path/to/search
```
- 查找文件名
```
find /path/to/search -name "string"
```
- 查看磁盘信息
```
df -h
```
- 查看文件夹大小（前者仅仅查看目录，后者查看目录以及所有子项）
```
du -sh /path/to/look
du -h /patt/to/look
```
- 查看 tcp 网络
```
netstat -atlnp
```

## 查看相关信息
-查看CPU型号
```
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
```
- 查看物理CPU的个数
```
cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l
```
- 查看逻辑CPU的个数
```
cat /proc/cpuinfo |grep "processor"|wc -l
```
- 查看每个CPU中core的个数(即核数)
```
cat /proc/cpuinfo |grep "cores"|uniq
```
- 查看操作系统内核信息
```
uname -a
```
- 查看CPU运行在32bit还是64bit模式
```
getconf LONG_BIT
```
- 查看内存总量
```
grep MemTotal /proc/meminfo  
```
- 查看空闲内存总量
```
grep MemFree /proc/meminfo
```

## 常见信息
系统日志一般位于 `/var/log` 中，
- 内核日志: `/var/log/dmesg_all`, `/var/log/dmesg`
- 系统日志： `/var/log/messages`，部分系统 会写入 `/var/adm/messages`