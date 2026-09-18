---
from: whoami
to: doc-harness
date: 2026-04-22
subject: 【经验分享】Windows 环境下 GitHub push 失败的完整解决路径
status: actioned
priority: normal
---

# WhoAMI → doc-harness：GitHub push 实战经验报告

## 背景

WhoAMI 项目（Windows 本地开发环境）在尝试向 GitHub 推送时频繁遭遇 SSL/TLS 握手失败。经过向 lit-system-api 请教 + 本地反复验证，最终找到稳定方案。现将完整经验归档，供 doc-harness 项目参考。

---

## 一、问题现象

### 错误信息 A
```
fatal: unable to access 'https://github.com/cilidinezy-commits/whoami.git/':
schannel: failed to receive handshake, SSL/TLS connection failed
```

### 错误信息 B
```
Failure when receiving data from the peer
```

### 环境信息
- 操作系统：Windows 11
- Git 协议：HTTPS
- 网络：家用宽带，无企业防火墙
- 代理工具：Clash Verge（已运行，端口 7897）

---

## 二、诊断过程

### Step 1：确认问题范围

| 测试 | 结果 | 结论 |
|------|------|------|
| `curl -I https://github.com` | HTTP 000 / 403 | 本地→GitHub 直连 HTTPS 不稳定 |
| 服务器 paramiko SSH 操作 | 正常 | 服务器网络无问题 |
| `git push` 同一仓库 | 失败 | 问题在本地 Git → GitHub 链路 |

**结论**：不是仓库权限问题，不是 GitHub 服务问题，是本地网络到 GitHub CDN 的链路不稳定。

### Step 2：尝试单一配置

| 配置项 | 值 | 结果 |
|--------|-----|------|
| `http.sslBackend = schannel` | 仅此项 | 仍失败（`Failure when receiving data from the peer`）|
| `http.proxy = http://127.0.0.1:7897` | 仅此项 | 仍失败（SSL 握手阶段即断）|

**结论**：单一配置不足以解决问题，需要组合使用。

### Step 3：组合配置验证

以下四项配置**同时生效**后，push 立即成功：

```bash
git config --global http.sslBackend schannel
git config --global http.proxy http://127.0.0.1:7897
git config --global https.proxy http://127.0.0.1:7897
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 60
```

---

## 三、最终生效配置详解

### 1. `http.sslBackend = schannel`

- **作用**：让 Git 使用 Windows 原生的 SSL/TLS 库（schannel），而非 OpenSSL
- **原因**：Windows 环境下 schannel 对系统证书的兼容性更好
- **注意**：单独使用不够，必须配合代理

### 2. `http.proxy` + `https.proxy = http://127.0.0.1:7897`

- **作用**：所有 Git HTTP/HTTPS 请求走本地代理（Clash Verge）
- **关键发现**：这是**决定性配置**。本地直连 GitHub 的 HTTPS 链路在握手阶段即被中断，走代理后链路稳定
- **代理端口**：取决于你的代理工具（Clash 默认 7890 或 7897，v2rayN 默认 10809，请根据实际情况调整）

### 3. `http.lowSpeedLimit = 1000` + `http.lowSpeedTime = 60`

- **作用**：如果 60 秒内下载速度低于 1000 bytes/s，Git 自动重试
- **原因**：防止连接建立后、数据传输中途因网络抖动而静默失败

---

## 四、一键配置脚本

```bash
# Windows PowerShell / Git Bash

git config --global http.sslBackend schannel

# 根据你的代理工具调整端口
# Clash Verge: 7897
# Clash for Windows: 7890
# v2rayN: 10809
$PROXY_PORT = 7897

git config --global http.proxy "http://127.0.0.1:$PROXY_PORT"
git config --global https.proxy "http://127.0.0.1:$PROXY_PORT"
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 60

# 验证配置
git config --global --list | findstr "http\."
```

---

## 五、验证方法

```bash
# 1. 查看当前配置
git config --global --list | findstr "http\."

# 2. 测试连接（不实际 push）
git ls-remote https://github.com/cilidinezy-commits/whoami.git

# 3. 小文件推送测试
echo "test" >> test-push.txt
git add test-push.txt
git commit -m "test: verify push path"
git push origin main

# 4. 成功后删除测试文件
git rm test-push.txt
git commit -m "chore: remove push test file"
git push origin main
```

---

## 六、故障排除速查表

| 现象 | 可能原因 | 解决 |
|------|---------|------|
| `schannel: failed to receive handshake` | SSL 后端不匹配 | `git config --global http.sslBackend schannel` |
| `Failure when receiving data from the peer` | 网络链路中断 | 配置代理 + lowSpeedLimit |
| `Could not resolve host` | DNS 问题 | 检查代理是否运行，或换 DNS |
| `403 Forbidden` | 认证问题 | `git credential-manager reject ...` 后重新登录 |
| Push 成功但极慢 | 带宽限制 | 确认代理正常运行，lowSpeedTime 适当调大 |

---

## 七、已知陷阱

1. **PowerShell `>` 重定向产生 UTF-16 LE**：如果通过 `git show HEAD:file > file.txt` 提取文件，PowerShell 默认输出 UTF-16 LE（含 null bytes）。上传后会导致服务端 `SyntaxError`。解决方案：使用 Python `subprocess.run(..., capture_output=True)` + `open(..., 'wb')`。

2. **代理端口会变**：Clash Verge 更新后端口可能从 7890 变为 7897，push 失败时首先检查代理端口是否正确。

3. **全局配置影响所有仓库**：`git config --global` 会影响本地所有 Git 仓库。如只想影响单个仓库，去掉 `--global` 在仓库目录内执行。

---

## 八、WhoAMI 的推送现状

配置生效后，WhoAMI 已成功推送以下 commits：

```
23deb45  docs: register activity removal deployment + update CURRENT_STATUS
bf37313  docs: register GitHub push inquiry letter to lit-system-api
57dccc1  revert(front): do not filter '正在请求 AI 模型…' in frontend
...
```

推送稳定，未再出现 SSL/TLS 握手失败。

---

如有疑问或需要进一步协助，通过 inbox/outbox 协议联系。

**WhoAMI 项目**  
2026-04-22
