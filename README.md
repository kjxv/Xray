# Xray 视频教程固定版

本仓库是 [233boy/Xray](https://github.com/233boy/Xray) 的视频教程分支，由 `kjxv` 维护。它是运行在 Linux 服务器上的 **Xray 一键安装和命令行管理脚本**，提供终端菜单；不包含网页管理面板或客户端应用。

教程固定标签：`tutorial-v1.35`。安装、脚本更新和重装均使用本仓库的固定版本，原作者后续修改菜单或功能不会自动影响本教程。

| 内容 | 固定版本 / 来源 |
| --- | --- |
| 管理脚本 | `kjxv/Xray` 的 `tutorial-v1.35` 标签，原脚本版本 `v1.35` |
| Xray 内核 | `XTLS/Xray-core` 的 `v26.3.27` |
| Caddy（添加 TLS 协议时安装） | `caddyserver/caddy` 的 `v2.11.7` |
| jq（系统未安装时下载） | `jqlang/jq` 的 `jq-1.7.1` |
| geoip.dat / geosite.dat | 固定 Xray 内核发行包附带的数据 |

上述默认值集中在 `src/release.sh`。系统已安装的 jq、操作系统软件包、客户端、证书及外部网站不在此版本锁定范围内。

## 安装

适用于有 root 权限的 Ubuntu、Debian、CentOS 或 Alpine 服务器，支持 x86_64 和 ARM64。Alpine 需要先安装 Bash 和 OpenRC。TLS 协议通常还需要域名解析及可用的 80 / 443 端口；默认安装创建 VLESS-REALITY 配置。

**维护者首次使用前，需先提交这些修改并推送 `tutorial-v1.35` 标签。** 发布步骤见 [教程版本维护](docs/TUTORIAL_RELEASE.md)。标签尚未发布时，以下在线安装命令会报错，不会回退到其他版本。

在 Linux 服务器以 root 身份执行：

```bash
curl -fL https://raw.githubusercontent.com/kjxv/Xray/tutorial-v1.35/install.sh -o /tmp/xray-tutorial-install.sh && bash /tmp/xray-tutorial-install.sh
```

没有 curl 时使用 wget：

```bash
wget -O /tmp/xray-tutorial-install.sh https://raw.githubusercontent.com/kjxv/Xray/tutorial-v1.35/install.sh && bash /tmp/xray-tutorial-install.sh
```

已经克隆本仓库并切换到教程标签时，也可以在仓库目录运行：

```bash
bash install.sh --local-install
```

发布标签前，维护者也可用本地安装方式验证尚未发布的改动。正式录制和向观众提供的命令应使用已发布的固定标签，不要使用 `main` 或 `releases/latest`。

## 常用操作与更新行为

```bash
xray                         # 打开终端菜单
xray add reality             # 添加 VLESS-REALITY 配置
xray info                    # 查看配置及客户端导入链接
xray qr                      # 显示二维码
xray version                 # 查看脚本和内核版本
xray help                    # 查看完整帮助及教程版本清单
```

`xray update` 默认恢复教程内核版本；`xray update caddy` 恢复教程 Caddy 版本；`xray update dat` 恢复固定内核附带的数据。`xray update sh` 和 `xray update.sh` 仅检查本教程的脚本标签，不下载上游最新脚本，也不接受其他脚本版本。

显式执行 `xray update core <版本号>`、`xray update caddy <版本号>` 或安装时使用 `--core-version <版本号>`，仍可自行切换依赖版本；这样会偏离教程默认环境。`xray reinstall` 保留本机脚本快照进行本地重装，内核回到教程默认值；和原版一样，重装会经过卸载流程并重新生成配置，需要保留的配置应提前备份。

项目完整作用、用途及各文件职责见 [项目说明](docs/PROJECT_OVERVIEW.md)。

## 原项目介绍

最好用的 Xray 一键安装脚本 & 管理脚本

# 特点

- 快速安装
- 无敌好用
- 零学习成本
- 自动化 TLS
- 简化所有流程
- 屏蔽 BT
- 屏蔽中国 IP
- 使用 API 操作
- 兼容 Xray 命令
- 强大的快捷参数
- 支持所有常用协议
- 一键添加 VLESS-REALITY (默认)
- 一键添加 Shadowsocks 2022
- 一键添加 VMess-(TCP/mKCP)
- 一键添加 VMess-(WS/gRPC)-TLS
- 一键添加 VLESS-(WS/gRPC/XHTTP)-TLS
- 一键添加 Trojan-(WS/gRPC)-TLS
- 一键添加 VMess-(TCP/mKCP) 动态端口
- 一键启用 BBR
- 一键更改伪装网站
- 一键更改 (端口/UUID/密码/域名/路径/加密方式/SNI/动态端口/等...)
- 还有更多...

# 设计理念

设计理念为：**高效率，超快速，极易用**

脚本基于作者的自身使用需求，以 **多配置同时运行** 为核心设计

并且专门优化了，添加、更改、查看、删除、这四项常用功能

你只需要一条命令即可完成 添加、更改、查看、删除、等操作

例如，添加一个配置仅需不到 1 秒！瞬间完成添加！其他操作亦是如此！

脚本的参数非常高效率并且超级易用，请掌握参数的使用

# 文档

安装及使用：https://233boy.com/xray/xray-script/

# 帮助

使用：`xray help`

```
Xray script v1.35 by 233boy
Usage: xray [options]... [args]...

基本:
   v, version                                      显示当前版本
   ip                                              返回当前主机的 IP
   pbk                                             同等于 xray x25519
   get-port                                        返回一个可用的端口
   ss2022                                          返回一个可用于 Shadowsocks 2022 的密码

一般:
   a, add [protocol] [args... | auto]              添加配置
   c, change [name] [option] [args... | auto]      更改配置
   d, del [name]                                   删除配置**
   i, info [name]                                  查看配置
   qr [name]                                       二维码信息
   url [name]                                      URL 信息
   log                                             查看日志
   logerr                                          查看错误日志

更改:
   dp, dynamicport [name] [start | auto] [end]     更改动态端口
   full [name] [...]                               更改多个参数
   id [name] [uuid | auto]                         更改 UUID
   host [name] [domain]                            更改域名
   port [name] [port | auto]                       更改端口
   path [name] [path | auto]                       更改路径
   passwd [name] [password | auto]                 更改密码
   key [name] [Private key | atuo] [Public key]    更改密钥
   type [name] [type | auto]                       更改伪装类型
   method [name] [method | auto]                   更改加密方式
   sni [name] [ ip | domain]                       更改 serverName
   seed [name] [seed | auto]                       更改 mKCP seed
   new [name] [...]                                更改协议
   web [name] [domain]                             更改伪装网站

进阶:
   dns [...]                                       设置 DNS
   dd, ddel [name...]                              删除多个配置**
   fix [name]                                      修复一个配置
   fix-all                                         修复全部配置
   fix-caddyfile                                   修复 Caddyfile
   fix-config.json                                 修复 config.json

管理:
   un, uninstall                                   卸载
   u, update [core | sh | dat | caddy] [ver]       恢复教程固定版本; core/caddy 可显式指定版本
   U, update.sh                                    检查教程固定脚本版本
   s, status                                       运行状态
   start, stop, restart [caddy]                    启动, 停止, 重启
   t, test                                         测试运行
   reinstall                                       重装脚本

测试:
   client [name]                                   显示用于客户端 JSON, 仅供参考
   debug [name]                                    显示一些 debug 信息, 仅供参考
   gen [...]                                       同等于 add, 但只显示 JSON 内容, 不创建文件, 测试使用
   genc [name]                                     显示用于客户端部分 JSON, 仅供参考
   no-auto-tls [...]                               同等于 add, 但禁止自动配置 TLS, 可用于 *TLS 相关协议
   xapi [...]                                      同等于 xray api, 但 API 后端使用当前运行的 Xray 服务

其他:
   bbr                                             启用 BBR, 如果支持
   bin [...]                                       运行 Xray 命令, 例如: xray bin help
   api, x25519, tls, run, uuid  [...]              兼容 Xray 命令
   h, help                                         显示此帮助界面

谨慎使用 del, ddel, 此选项会直接删除配置; 无需确认
反馈问题) https://github.com/kjxv/Xray/issues
教程文档) https://github.com/kjxv/Xray/blob/tutorial-v1.35/README.md
原作者文档) https://233boy.com/xray/xray-script/
```

## 来源与许可

保留原作者 `233boy` 的署名、原项目文档和 GNU GPL v3 许可证。本仓库的改动主要是教程版本锁定、下载入口及发布流程调整，未改动现有协议菜单和配置管理流程。原作者在线文档可能继续更新，涉及教程安装和更新的行为请以本标签下的说明为准。
