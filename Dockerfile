# 切换为 Debian Bookworm Slim，拥有更完善的底层 C 库支持
FROM python:3.10-slim-bookworm

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on

WORKDIR /app

# 1. 安装 ffmpeg 以及 ARMv7 编译必备的 C/Rust 核心工具链
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg build-essential python3-dev cargo pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY . .

# 2. 加入 piwheels 源（专门为 ARMv7 预编译的仓库），大幅减少源码编译时间
RUN pip install -r requirements.txt --no-cache-dir --extra-index-url https://www.piwheels.org/simple

CMD ["python", "bot/main.py"]