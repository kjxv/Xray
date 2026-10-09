# 教程版本维护

## 首次发布

先确认视频应采用本次锁定的默认版本：脚本 `v1.35`、Xray `v26.3.27`、Caddy `v2.11.7`。如果视频已经使用其他依赖版本，应在发布标签前修改 `src/release.sh` 并重新验证。

在本仓库运行以下命令，提交本次修改、创建标签并推送到自己的 GitHub 仓库：

```bash
git add .gitattributes README.md install.sh src .github/workflows/release.yml docs tests
git commit -m "Pin Xray deployment for tutorial-v1.35"
git tag -a tutorial-v1.35 -m "Xray video tutorial fixed version"
git push origin main
git push origin tutorial-v1.35
```

普通 `main` 推送不会发布版本。推送教程标签后，GitHub Actions 会校验仓库与标签、运行离线检查，并生成该标签的 `code.zip` Release。源码安装直接读取同一标签，不依赖 Release 构建是否完成，但应等检查通过，再录制教程并向观众提供 README 中的安装命令。

如果仓库的 Actions 尚未启用，需要在自己的仓库 Actions 页面启用工作流。

## 验证与录制

在 Linux 或 Git Bash 中先执行离线验证（需要 Bash、Python 3、unzip 和 tar）：

```bash
bash tests/tutorial-lock.sh
```

然后在干净的 Linux 测试服务器安装已发布标签，检查默认 REALITY 配置及客户端连接；如果教程涉及 TLS 协议，再检查域名解析、Caddy 和证书获取。离线验证不会启动服务，也不会替代这些实际服务器检查。

记录 `xray version` 和 `xray help` 显示的版本信息，并让视频文字、视频简介和示例命令均使用 `tutorial-v1.35`。如果需要让演示数据也完全一致，使用明确的协议、端口和域名参数；脚本自动生成的 UUID、密钥及端口每次都会不同。

## 后续教程

为新教程创建一个新的标签，例如 `tutorial-v1.35-lesson2`：同时修改 `src/release.sh` 和 `install.sh` 顶部的 `is_sh_ref`，按需修改依赖版本，并同步 README 和发布命令中的标签。校验通过后，提交并发布新标签。

不要移动、强制推送或删除旧教程标签，也不要替换旧版 Release 资产。工作流会拒绝覆盖已发布的 Release；GitHub 仓库设置中还可为 `tutorial-*` 添加禁止更新和删除标签的规则，防止手动操作改变教程源码。

Xray 和 Caddy 继续从各自的官方发行版下载。本仓库固定的是版本选择，没有复制这些二进制文件；GitHub 和官方发行资产仍需可访问。需要长期离线保存时，可另外备份对应版本的二进制包和哈希，并在新的教程标签中明确记录来源。
