# ---- 第一阶段：构建依赖环境 (Builder) ----
FROM python:3.10-slim-bookworm AS builder

WORKDIR /app

# 创建并激活纯净的 Python 虚拟环境
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

# 核心优化：amd64/arm64 已有官方原生 Wheel，直接安装，彻底摒弃 C/Rust 编译器与 piwheels
RUN pip install --no-cache-dir -r requirements.txt


# ---- 第二阶段：极简运行环境 (Runner) ----
FROM python:3.10-slim-bookworm

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# 仅安装媒体与图片处理必需的运行时系统库 (不含任何多余构建工具)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg libjpeg62-turbo zlib1g && \
    rm -rf /var/lib/apt/lists/*

# 从 Builder 阶段拷贝配置好的 Python 环境
COPY --from=builder /opt/venv /opt/venv

COPY . .

CMD ["python", "bot/main.py"]
