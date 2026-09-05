# 🤖 FreeAI-Telegram-Bot

![Python](https://img.shields.io/badge/Python-3.10+-blue.svg?logo=python&logoColor=white)
![Telegram](https://img.shields.io/badge/Telegram-Bot-2CA5E0.svg?logo=telegram&logoColor=white)
![OpenRouter](https://img.shields.io/badge/API-OpenRouter-6C5CE7.svg)
![Hugging Face](https://img.shields.io/badge/AI-HuggingFace-FFD21E.svg?logo=huggingface&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green.svg)

通过 **OpenRouter** + **Hugging Face**，将强大的聊天 AI 和画图 AI 完美接入 Telegram Bot。本项目对原生代码进行了深度优化与重构，解除官方 API 强绑定限制，实现完全免费的多模态 AI 助手体验。

---

## ✨ 核心特性

*   💬 **无限制对话**：原生支持 OpenRouter 聚合接口，轻松调用 `MiniMax-M3`、`Qwen3.8`、`DeepSeek` 等顶级免费大模型。
*   🎨 **高阶 AI 画图**：内置 Hugging Face Inference Providers，支持 `FLUX.1-schnell`、`Stable Diffusion XL` 等顶级开源视觉模型，彻底告别旧版 410/403 报错。
*   ⚡ **极简容器部署**：专为 Python 容器和 Serverless 环境优化，无缝兼容各类云面板与本地服务器。
*   🛡️ **严格白名单过滤**：支持自定义 TG 用户 ID 鉴权，防滥用、防盗刷。

---

## 🚀 部署环境支持

本项目运行轻量，理论上支持任何提供 Python 3.10+ 运行环境的设备或平台。

*   **PaaS / 容器托管面板**：Katabump、Serv00、Fly.io、Render、Hugging Face Spaces 等。
*   **云服务器 (VPS)**：AWS、GCP、Oracle Cloud (OCI) 等各类 Linux 主机。
*   **本地服务器 / HomeLab**：DIY NAS、ARM 架构单板机（如玩客云、N1、OECT、RK3566 开发板、已刷Armbian的S905系列盒子等）、Debian/Ubuntu/OpenWrt 软路由环境。

---

## 📖 详细部署教程（以 Katabump 为例）

本教程以 [Katabump](https://katabump.com/) 的 Python 容器为例，其他提供 Python 环境的面板（如 Pterodactyl 翼龙面板）操作逻辑完全一致。

### 1. 准备核心密钥
*   **Telegram Bot Token**：在 TG 中向 `@BotFather` 发送 `/newbot` 获取。
*   **OpenRouter API Key**：前往 [OpenRouter 控制台](https://openrouter.ai/keys) 免费生成。
*   **Hugging Face Token**：前往 [HF Settings](https://huggingface.co/settings/tokens) 创建一个 `⚡Inference` 或 `Read` 权限的密钥。
  (建议用⚡Inference)

### 2. 上传并解压项目
1.  在本项目 GitHub 页面点击 **Code -> Download ZIP**。
2.  进入 Katabump 面板的 **Files（文件管理）**，上传该 ZIP 并右键点击 **Unarchive（解压）**。
3.  确保项目核心文件（如 `requirements.txt` 和 `bot/` 文件夹）直接位于 `/home/container/` 根目录。 (建议直接用SFTP上传)

### 3. 配置运行依赖
1.  在面板 **Files** 中找到 `requirements.txt`。
2.  确保文件内包含 `huggingface_hub`（若无则手动添加一行）。
3.  容器启动时会自动抓取并安装所有依赖。

### 4. 环境变量配置 (.env)
打开根目录的 `.env`文件，填入以下参数：

```
# 1️⃣--- TG 机器人基础配置 ---
TELEGRAM_BOT_TOKEN=你的TG机器人Token
ALLOWED_TELEGRAM_USER_IDS=你的纯数字TG_ID (多个用逗号隔开，填 * 允许所有人)
ADMIN_USER_IDS=你的纯数字TG_ID (用于解锁 /stats 数据统计)


# 2️⃣--- 文本聊天配置 (OpenRouter) ---
OPENAI_BASE_URL=https://openrouter.ai/api/v1
OPENAI_API_KEY=sk-or-xxxx你的OpenRouter密钥xxxx
OPENAI_MODEL=minimax/minimax-m3:free
VISION_MODEL="minimax/minimax-m3:free"
MAX_TOKENS=2000


# 3️⃣--- 画图配置 (Hugging Face) ---
ENABLE_IMAGE_GENERATION=true
HF_TOKEN=hf_xxxx你的HF密钥xxxx
HF_IMAGE_MODEL=black-forest-labs/FLUX.1-schnell
ENABLE_IMAGE_GENERATION=true

```
（备注：TG_ID通过 `@getidsbot` 或 `@userinfobot` 机器人获取）
<br>

### 5. 校准启动命令并运行

1. 进入面板的 **Startup（启动设置）** 标签页。找到 **Docker Image** 选`Python 3.12`
2. 找到 **Python File** 启动变量，将默认值修改为：`bot/main.py`。
3. 返回 **Console（控制台）**，点击 **Start** 启动服务器。
4. 当控制台输出 `Application started`，即可前往 Telegram 向机器人发送 `/start` 开始体验！

---

## 💡 温馨提示与排坑指南

* **替代环境方案**：如遇 Katabump 平台无法注册、资源售罄或容器频繁离线，建议迁移至 Serv00、Render，或直接使用你手头的云服务器部署。
* **资源合规使用**：无论是容器托管商的计算资源，还是 OpenRouter / Hugging Face 提供的免费 API 额度，**最好是根据自己的实际需求去使用**。TG Bot 建议作为个人测试、技术学习及备用 AI 工具使用，共同维护良好的开源白嫖生态。
* **画图模型报错 (`403 Forbidden`)**：Hugging Face 的部分新模型（如 SD 3.5 / FLUX）已被移出免费 Serverless 额度或需要签署网页免责协议。若遇 403 错误，请在 `.env` 中降级至完全免费开源的 `black-forest-labs/FLUX.1-schnell` 或 `stabilityai/stable-diffusion-xl-base-1.0`
* **API 限流 (`429 Rate Limit`)**：遇到免费通道拥堵时，稍等几分钟后重新发送指令即可恢复。

---

## 🙏 致谢与参考项目

本项目的实现离不开以下开源项目与服务商的支持：

* [n3d1117/chatgpt-telegram-bot](https://github.com/n3d1117/chatgpt-telegram-bot/tree/main) - 核心基础框架
* [benincasantonio/gemini-ai-telegram-bot](https://github.com/benincasantonio/gemini-ai-telegram-bot) - Vercel 无服务器部署思路参考
* [佬王 eooce](https://github.com/eooce) - 优秀的开源项目与导航灵感
* [OpenRouter](https://openrouter.ai/models?q=free&output_modalities=text) - 顶级的开源大模型聚合分发接口
* [Hugging Face](https://huggingface.co/) - 开源 AI 社区及 Inference API 算力支持
* [AMD Radeon TokenFactory](https://developer.amd.com.cn/radeon/tokenfactory) - AMD GPU Cloud 提供的优质 OpenAI 兼容节点支持
* [环境变量.env进阶设置](https://github.com/n3d1117/chatgpt-telegram-bot/blob/main/README.md) - 参数自定义修改请参考原项目文档
