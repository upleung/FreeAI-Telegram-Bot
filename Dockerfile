# ---- 第一阶段：高权限编译沙盒 (Builder) ----
FROM python:3.10-slim-bookworm AS builder

# 强制 Cargo 使用稀疏 HTTP 协议，阻止下载庞大的 Git 注册表以防 inode 溢出报错
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc g++ build-essential cargo pkg-config \
    libjpeg-dev zlib1g-dev libpng-dev libffi-dev

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
# 核心防御：强制使用 piwheels 源，并指定 tiktoken 仅使用二进制包，彻底绕过 Rust 源码本地慢速编译
RUN pip install --no-cache-dir --prefer-binary --only-binary=tiktoken -r requirements.txt --extra-index-url https://www.piwheels.org/simple

# ---- 第二阶段：极简运行环境 (Runner) ----
FROM python:3.10-slim-bookworm

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg libjpeg62-turbo zlib1g && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv
COPY . .

CMD ["python", "bot/main.py"]
