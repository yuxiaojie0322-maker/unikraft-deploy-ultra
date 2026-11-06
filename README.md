# ⚡ Unikraft Ultra Deploy (3 账号 5 地区 6 节点极光版)

基于 [Unikraft Cloud](https://unikraft.com) 硬件级 MicroVM 的 **极速 + 高颜值** VLESS-WS-TLS / Cloudflare Argo 自动化矩阵部署方案。

---

## 🌟 相比原版 `vevc/unikraft-deploy` 的核心升级

1. **🚀 镜像与启动提速 300%**：弃用臃肿的 `debian:trixie-slim`，改用 `alpine:3.21` 极简底座，镜像体积缩小 80%，打包与冷启动控制在 **10~15ms**。
2. **⚡ 油管 4K 秒开网络调优**：
   - 服务端与客户端订阅双向开启 **WebSocket 0-RTT Early Data (`ed=2048`)**，降低首包握手延迟。
   - 内置 `1.1.1.1` / `8.8.8.8` **`prefer_ipv4`** DNS 策略，彻底解决双栈环境下 Google/YouTube 解析卡顿。
   - 每个实例自动生成 **原生直连 (`Direct`) + Argo 隧道 (`Argo`) + 2 条 CF 优选 IP (`cf.090227.xyz` / `visa.com.sg`)** 共 4 条互补线路。
3. **🌐 一键部署 3 账号 5 地区 6 节点黄金矩阵**：
   - 每个 Unikraft 免费账号可同时运行 **2 个实例**；3 个账号共计 **6 个免费实例额度**。
   - 5 个地区（`sin`、`sfo`、`fra`、`was`、`dal`）全覆盖 + 新加坡主力区双活热备，只需点 **1 次 `Run workflow`**，自动合并生成 **1 个汇总所有节点的加密总订阅链接**！
4. **🎨 极光毛玻璃节点控制中心 (`docs/index.html`)**：
   - 纯前端 Web Crypto AES-256-CBC 零知识解密，支持 **浏览器本地记住 UUID（打开链接 0 点击自动秒解）**。
   - 自动解析生成 **国旗节点卡片、二维码扫码弹窗、浏览器实时延迟测速、Base64 订阅复制、一键导出 Clash (Mihomo) 完整 YAML 配置**。
5. **🔄 全自动免维护动态保活 (`keepalive.yml`)**：自动通过 Token 查询 3 个账号下所有活跃实例域名并定时 Ping 保活，无需手动硬编码修改域名。

---

## 🗺️ 3 个账号 × 5 个地区的「黄金 6 节点排布方案」

> **为什么这样配？**
> Unikraft 免费版限制是 **「每个账号最多同时运行 2 个节点（全账号总计 2 个，不是每个地区 2 个）」**。因此你手里的 **3 个账号 = 6 个节点槽位**，恰好可以把 **5 个地区全部占满，并在延迟最低的新加坡（`sin`）放 2 个账号做双活负载均衡**！

| 账号槽位 | 节点 1 | 节点 2 | 角色定位与优势 |
| :---: | :---: | :---: | :--- |
| **账号 A** (`UNIKRAFT_TOKEN_A`) | 🇸🇬 `sin` (新加坡 1) | 🇺🇸 `sfo` (旧金山美西) | **主力极速组**：亚洲 + 美西最低延迟，日常刷 4K 视频首选 |
| **账号 B** (`UNIKRAFT_TOKEN_B`) | 🇸🇬 `sin` (新加坡 2) | 🇩🇪 `fra` (德国法兰克福) | **亚欧冗余组**：新加坡双账号双活防炸 + 欧洲高速节点覆盖 |
| **账号 C** (`UNIKRAFT_TOKEN_C`) | 🇺🇸 `was` (华盛顿美东) | 🇺🇸 `dal` (达拉斯美中) | **北美解锁组**：纯正美国双区，专门解锁 ChatGPT / Claude / 流媒体 |

---

## ⚙️ GitHub Secrets 配置指南

进入你 Fork 或上传后的仓库：**`Settings` -> `Secrets and variables` -> `Actions` -> `New repository secret`**：

### 1. 必填核心配置（只需 4 项即可跑通 3 账号 6 节点！）

| Secret 名称 | 是否必填 | 说明 |
| :--- | :---: | :--- |
| `UUID` | **必填** | 节点连接密码 & 极光面板解密密钥（用 `uuidgen` 生成一个标准 UUID） |
| `UNIKRAFT_TOKEN_A` | **必填** | 第 1 个 Unikraft 账号的 API Token（负责 `sin` + `sfo`） |
| `UNIKRAFT_TOKEN_B` | 推荐 | 第 2 个 Unikraft 账号的 API Token（负责 `sin` + `fra`） |
| `UNIKRAFT_TOKEN_C` | 推荐 | 第 3 个 Unikraft 账号的 API Token（负责 `was` + `dal`） |

### 2. 可选 Cloudflare Argo 隧道配置（按需配置）

> 如果不填 Argo 配置，脚本会自动部署 **Unikraft 原生直连模式**（速度同样极快）。
> 如果想为 6 个节点分别绑定固定 Cloudflare Argo 隧道（在 Cloudflare Zero Trust -> Networks -> Tunnels 创建，Service 填 `HTTP://127.0.0.1:8080`），可按需添加对应的 Secret：

| 对应节点 | Tunnel Token Secret 名称 | 绑定的域名 Secret 名称 |
| :--- | :--- | :--- |
| 账号 A - 新加坡 (`sin`) | `ARGO_TOKEN_A_SIN` | `ARGO_DOMAIN_A_SIN` |
| 账号 A - 旧金山 (`sfo`) | `ARGO_TOKEN_A_SFO` | `ARGO_DOMAIN_A_SFO` |
| 账号 B - 新加坡 (`sin`) | `ARGO_TOKEN_B_SIN` | `ARGO_DOMAIN_B_SIN` |
| 账号 B - 法兰克福 (`fra`) | `ARGO_TOKEN_B_FRA` | `ARGO_DOMAIN_B_FRA` |
| 账号 C - 华盛顿 (`was`) | `ARGO_TOKEN_C_WAS` | `ARGO_DOMAIN_C_WAS` |
| 账号 C - 达拉斯 (`dal`) | `ARGO_TOKEN_C_DAL` | `ARGO_DOMAIN_C_DAL` |
| *单账号/通用回退默认* | `ARGO_TOKEN` | `ARGO_DOMAIN` |

---

## 🚀 一键部署与使用流程

1. **开启 GitHub Pages（仅首次需要）**：
   - 打开仓库 **`Settings` -> `Pages`**
   - **Build and deployment** 下：`Source` 选择 `Deploy from a branch`，`Branch` 选择 `main` 并把文件夹选为 **`/docs`**，点击 `Save`。
2. **一键启动 6 节点矩阵部署**：
   - 打开仓库 **`Actions` -> `Create Unikraft Instance (Ultra Matrix)` -> `Run workflow`**
   - 保持默认的 **`ALL - 一键部署 3 账号 6 节点黄金矩阵`**，点击绿色的 **`Run workflow`**。
3. **打开极光面板获取订阅**：
   - 部署完成后，点击 Actions 页面底部的 **Job Summary** 中的链接。
   - 输入你的 `UUID`（勾选记住 UUID 后下次免输），即可看到 **全部 6 个实例（最高 24 条直连/Argo/优选IP线路）** 的可视化卡片、二维码，或一键下载 Clash 配置文件！

