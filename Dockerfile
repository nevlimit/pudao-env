FROM python:3.10-slim

ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DAGSTER_HOME=/opt/dagster/dagster_home

# 系统依赖只在需要编译时用；confluent-kafka 我们尽量用预编译 wheel
RUN apt-get update && apt-get install -y --no-install-recommends gcc build-essential ca-certificates

# Dagster 及集成（和 webserver 版本锁一致）
RUN pip install "dagster==1.11.7" "dagster-webserver==1.11.7" \
                dagster-postgres dagster-docker

# 先装纯 Python 客户端；再装 confluent-kafka，尽量只用二进制 wheel，避免编译
RUN pip install --no-cache-dir kafka-python==2.0.2 && \
    pip install --no-cache-dir --only-binary=:all: confluent-kafka==2.5.0

# 清理构建依赖（如果上一步都走 wheel，下面可安全删）
RUN apt-get purge -y gcc build-essential && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# 建家目录并降权运行（更安全）
RUN useradd -m -u 10101 dagster && mkdir -p $DAGSTER_HOME && chown -R dagster:dagster /opt/dagster
USER 10101

WORKDIR /opt/dagster
EXPOSE 3000
