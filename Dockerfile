# ---- 第一阶段：高权限编译沙盒 (Builder) ----
FROM python:3.10-slim-bookworm AS builder

# 🚀 核心修复：解决 QEMU ARMv7 下 Rust 编译 tiktoken 报 "Value too large" 的核心 Bug
# 强制 Cargo 使用稀疏 HTTP 协议，阻止其下载庞大的 Git 注册表
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

WORKDIR /app

# 安装 C/C++ 编译器、Rust (Cargo) 以及 Pillow 必备的图像底层头文件
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc g++ build-essential cargo pkg-config \
    libjpeg-dev zlib1g-dev libpng-dev libffi-dev

# 创建纯净的 Python 虚拟环境
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 注入 piwheels 源，强制优先使用已构建好的预编译 wheel
COPY requirements.txt .
RUN pip install --no-cache-dir --prefer-binary --only-binary=tiktoken -r requirements.txt --extra-index-url https://www.piwheels.org/simple


# ---- 第二阶段：极简运行环境 (Runner) ----
# 参考 playhub 的瘦身策略，仅保留运行所需环境
FROM python:3.10-slim-bookworm

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# 仅安装运行期必须的 ffmpeg 和动态链接库（甩掉所有编译工具，体积骤减）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg libjpeg62-turbo zlib1g && \
    rm -rf /var/lib/apt/lists/*

# 从 builder 阶段把编译好的、完美的 Python 虚拟环境完整复制过来
COPY --from=builder /opt/venv /opt/venv

COPY . .

CMD ["python", "bot/main.py"]
