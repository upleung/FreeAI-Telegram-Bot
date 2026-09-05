# 关于回答内容默认是 Markdown 格式的说明与解决方案

在将 MiniMax-M3 或其他主流大语言模型通过 OpenRouter 接入 Telegram Bot 后，很多用户会发现机器人的回答中带有 `**加粗**`、`### 标题`、`- 列表` 或代码块等原始 Markdown 语法标记，甚至有时候排版正常、有时候直接显示原始符号。

本文档详细解析该现象的技术成因、提供多种根治或优化方案，并附带常用的 Markdown 在线预览工具。

---

## 一、为什么大模型默认输出 Markdown 格式？

1. **预训练数据的通用标准**  
   现代大语言模型（包括 MiniMax-M3、DeepSeek、GPT、Claude 等）在训练阶段吸收了海量的 GitHub 代码、技术文档和百科数据，这些资料绝大多数使用 Markdown 编写。
2. **结构化表达的最优解**  
   纯文本无法直观表现层次结构。大模型利用 Markdown 中的 `#`（层级标题）、`*`（强调加粗）、```（代码高亮）和 `|`（表格）来输出结构清晰的内容。

---

## 二、为什么 Telegram 会直接显示原始 Markdown 符号？

Telegram 自身是支持富文本渲染的，但如果你在聊天框中看到了未渲染的原始符号（例如 `**文字**`），通常是触发了以下机制：

* **Telegram MarkdownV2 规则极其苛刻**  
  Telegram 的 `MarkdownV2` 解析引擎对未转义字符容错率极低。下划线 `_`、星号 `*`、方括号 `[]`、圆括号 `()`、点号 `.`、减号 `-` 等符号如果未成对闭合或未加反斜杠转义（`\.`），Telegram 服务端会直接拒绝接收并抛出错误（`Can't parse entities`）。
* **机器人的自动降级保护机制**  
  `chatgpt-telegram-bot` 内置了异常捕获逻辑：当检测到 Telegram 无法解析当前消息的 Markdown 标签时，为了避免整个机器人崩溃退出，代码会**自动降级为纯文本（Plain Text）**强制发送。这就导致排版失败的内容以最原始的文本形式展示在屏幕上。

---

## 三、解决方案

### 方案 1：通过 System Prompt 强制纯文本输出（最简单）
如果你完全不需要代码块或排版，只希望在手机上看到干净通顺的文本，可以直接通过系统提示词约束模型。

在 `.env` 中添加或修改系统人设（或在对话中使用 `/system` 指令）：

```ini
# 限制模型不使用任何 Markdown 格式
OPENAI_MODEL_PROMPT="你是一个友好的中文助手。请使用纯文本格式回答所有问题，严格禁止使用任何 Markdown 语法符号（不要使用 **加粗**、不要使用 # 标题、不要使用列表符号，直接分段输出自然语言）。"

```

### 方案 2：在机器人代码中优化 Markdown 容错

编辑 `bot/telegram_bot.py`，找到发送消息的相关逻辑：

* 如果不需要复杂格式，可以将 `parse_mode` 直接指定为 `None`，统一作为普通文本发送。
* 也可以将默认的 `ParseMode.MARKDOWN_V2` 切换为兼容性更好的 `ParseMode.HTML`，并在处理文本时将 Markdown 自动转换为 HTML 标签。

---

## 四、Markdown 在线快速预览与排版工具

当机器人输出了长篇复杂的技术文档、多列对比表格或代码方案，而 Telegram 手机端无法完整展示或排版错乱时，可以直接**复制机器人的回答内容**，粘贴到以下免登录的在线 Markdown 实时渲染平台进行查看：

| 平台名称 | 访问地址 | 特点说明 |
| --- | --- | --- |
| **Markdown Live Preview** | [markdownlivepreview.com](https://markdownlivepreview.com/) | 极简极速、双栏实时渲染，适合快速查看代码块与原生排版 |
| **墨滴 (LoveJade)** | [markdown.lovejade.cn](https://markdown.lovejade.cn/) | 支持丰富的主题样式，适合长文章排版及一键复制到公众号/知乎 |
| **菜鸟工具 Markdown 在线编辑** | [jyshare.com/front-end/10178](https://www.jyshare.com/front-end/10178/) | 国内网络访问秒开，支持分栏对比、即时导出 HTML 源码 |

---

## 五、使用建议

Telegram 移动端屏幕空间有限，复杂的 Markdown 表格和长代码在手机端体验较差。对于日常问答、闲聊和轻量翻译，建议保持纯文本或轻度加粗；遇到大段代码、数据报表或长篇综述时，配合上述在线渲染预览平台使用效果最佳。
