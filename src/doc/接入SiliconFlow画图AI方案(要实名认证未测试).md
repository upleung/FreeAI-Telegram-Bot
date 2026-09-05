强烈推荐使用 **硅基流动 (SiliconFlow)**。它是目前国内开发者最热门的 AI 接口聚合平台，优势在于：

* **完全免费**：其部署的 120 亿参数顶级开源画图模型 **FLUX.1-schnell** 支持永久免费调用（Serverless 模式）。
* **生成极速**：通过潜在对抗扩散蒸馏训练，只需 1 到 4 步即可生成高质量图片，彻底解决画质差的问题。
* **接口原生兼容**：它的 API 格式与 OpenAI 官方完全一致，可以直接利用机器人现有的 Python 依赖包。
* **双通道独立互不干扰**：我们可以用一段独立代码让机器人的“问答聊天”继续走 OpenRouter，而“画图”专门走硅基流动的 API。

**第一步：获取免费 API Key**

1. 访问硅基流动官网：[cloud.siliconflow.cn](https://cloud.siliconflow.cn/) 并注册账号。
2. 登录后，在左侧导航栏找到 **API 密钥 (API Keys)**，点击“新建 API 密钥”。
3. 复制生成的字符串（以 `sk-` 开头）。

**第二步：配置环境变量**

1. 进入 Katabump 面板的 **Files**，打开 `.env` 文件。
2. 在文件末尾新建一行，填入你刚刚获取的密钥：
`SILICONFLOW_API_KEY=sk-xxxxxx你的密钥xxxxxx`
3. 点击保存。

**第三步：修改画图代码**

1. 在 **Files** 中，再次打开 `bot/openai_helper.py`。
2. 找到 `async def generate_image(self, prompt: str):` 这一整段函数。
3. 将其**内部代码**完全替换为以下代码（请严格保持代码缩进对齐）：

```python
    async def generate_image(self, prompt: str):
        import os
        from openai import AsyncOpenAI
        
        try:
            # 读取 .env 中的专属密钥
            sf_api_key = os.environ.get("SILICONFLOW_API_KEY")
            if not sf_api_key:
                raise ValueError("未找到 API Key，请检查 .env 配置")
                
            # 独立初始化一个专门用于画图的客户端，与 OpenRouter 的聊天功能分离
            sf_client = AsyncOpenAI(
                api_key=sf_api_key,
                base_url="https://api.siliconflow.cn/v1"
            )
            
            # 调用永久免费的顶级画图模型 FLUX.1-schnell
            response = await sf_client.images.generate(
                model="black-forest-labs/FLUX.1-schnell",
                prompt=prompt,
                size="1024x1024" 
            )
            
            image_url = response.data[0].url
            return image_url, "1024x1024"
            
        except Exception as e:
            raise Exception(f"⚠️ 画图失败: {str(e)}") from e

```

4. 点击右下角 **Save Content**。
5. 返回 Katabump 的 **Console**，点击 **Restart** 重启容器即可在 TG 中正常使用 `/image`。

**进阶体验：使用赠送额度调用闭源/满血模型**
新注册硅基流动通常会自动赠送 14 元免费测试额度。如果你想用这笔额度体验画质更好、细节更丰富的收费级模型，只需把上面代码中的 `black-forest-labs/FLUX.1-schnell` 替换为以下任意一款：

* **`black-forest-labs/FLUX.1-dev`**：FLUX 系列的满血进阶版，文本理解与细节刻画更完美。
* **`stabilityai/stable-diffusion-3-5-large`**：Stable Diffusion 家族最新旗舰模型，对复杂提示词遵循度极高。
* **`Pro/black-forest-labs/FLUX.1-schnell`**：独占专用 GPU 节点的快速版本，出图速度更快。