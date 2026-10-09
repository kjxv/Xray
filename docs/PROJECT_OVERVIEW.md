# 项目作用与用途

## 它是什么

这是围绕 Xray-core 编写的 Bash 安装和管理工具，不是 Xray 内核本身。它在 Linux 服务器上下载内核、生成配置、注册后台服务，并提供 `xray` 命令及交互式终端菜单。客户端需要另外安装，再导入脚本生成的链接或二维码。

当前教程基于克隆时的提交 `34665f32768d149a94423a89b4cbb7d7643d1660`，原脚本版本为 `v1.35`。

## 可以用来做什么

- 在自己的服务器上部署代理服务，默认创建 VLESS-REALITY 配置。
- 同时管理多个连接配置：添加、查看、修改或删除协议、端口、UUID、密码、域名、路径及密钥。
- 使用 VLESS、VMess、Trojan、Shadowsocks / Shadowsocks 2022、SOCKS 等协议，以及 TCP、mKCP、WebSocket、gRPC、XHTTP 等组合。具体可选组合由菜单列出。
- 为基于域名的 TLS 协议安装 Caddy，自动配置证书及反向代理，并设置伪装网站。
- 生成客户端导入链接、二维码，以及用于参考的客户端 JSON 配置。
- 管理后台服务的启动、停止、重启、状态和日志，调整 DNS、出站 IPv4 / IPv6 优先级，或在内核支持时启用 BBR。
- 为视频教程提供固定、可复现的脚本界面和默认下载版本。

安装时的默认路由包含阻止 BitTorrent、中国 IP 和私有 IP 的规则，这会影响连接目标；它不是任意流量都无条件转发的工具。终端菜单中的“更改伪装网站”服务于 Caddy 反向代理，不是创建独立的网站管理系统。

## 主要文件职责

| 文件 | 职责 |
| --- | --- |
| `install.sh` | 系统、架构和依赖检查，下载固定脚本和内核，安装服务并生成首个 REALITY 配置 |
| `xray.sh` | `xray` 命令入口，记录原管理脚本版本 |
| `src/init.sh` | 初始化路径、平台和服务状态，加载教程版本并分发命令 |
| `src/core.sh` | 菜单、协议配置生成、增删改查、导入链接、服务管理和重装 |
| `src/release.sh` | 教程仓库、固定标签、依赖版本，以及源码归档校验和安装 |
| `src/download.sh` | 内核、脚本、规则数据和 Caddy 的固定版本下载 |
| `src/systemd.sh` | 创建 systemd 或 Alpine OpenRC 后台服务 |
| `src/caddy.sh` | 生成 Caddyfile、TLS 协议反向代理和伪装网站配置 |
| `src/help.sh` | 命令帮助和项目来源信息 |
| `src/dns.sh` / `src/ip.sh` | DNS 和出站 IP 优先级设置 |
| `src/log.sh` / `src/bbr.sh` | 日志设置和 BBR 开启 |
| `.github/workflows/release.yml` | 仅发布教程标签，校验版本并防止覆盖已有 Release |
| `tests/tutorial-lock.sh` | 离线检查安装、下载、更新、归档和重装的版本锁定行为 |

## 安装后的主要位置

- `/etc/xray/sh`：管理脚本及固定教程标签记录 `script-ref`。
- `/etc/xray/bin`：Xray 内核及规则数据。
- `/etc/xray/config.json`：日志、路由、API 等公共配置。
- `/etc/xray/conf`：不同协议的独立连接配置。
- `/var/log/xray`：日志。
- `/usr/local/bin/xray`：管理命令入口。
- `/etc/caddy`：启用自动 TLS 后的 Caddy 配置。

## 为什么仅克隆仓库不够

原安装器仍从原作者仓库获取最新 `code.zip`，管理命令还会查询上游最新版本；原发布流程又会在每次推送时使用相同的脚本版本标签发布。因此，仅复制代码或只修改 README 的安装网址，都不能确保实际下载的界面与视频一致。

本分支将安装器、管理脚本、规则数据、重装和发布流程统一到固定教程版本。仓库的 `main` 可以继续开发，已发布的视频始终引用原来的教程标签。
