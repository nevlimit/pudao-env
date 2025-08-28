FROM python:3.10-slim

ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DAGSTER_HOME=/opt/dagster/dagster_home

# 仅在需要编译时用到的系统依赖；confluent-kafka 争取走预编译 wheel
RUN apt-get update && apt-get install -y --no-install-recommends \
      gcc build-essential ca-certificates

# 一次性装齐：Dagster + 依赖
# - jsonschema 指定版本
# - confluent-kafka 单独一行并强制 only-binary，避免编译 librdkafka
RUN pip install --no-cache-dir \
      "dagster==1.11.7" "dagster-webserver==1.11.7" \
      dagster-postgres dagster-docker \
      jsonschema==4.22.0 \
      kafka-python==2.0.2 && \
    pip install --no-cache-dir --only-binary=:all: \
      confluent-kafka==2.5.0

# 清理构建依赖
RUN apt-get purge -y gcc build-essential && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# 创建运行用户并确保 DAGSTER_HOME 可写
RUN useradd -m -u 10101 dagster && mkdir -p "$DAGSTER_HOME" && chown -R dagster:dagster /opt/dagster
USER 10101

WORKDIR /opt/dagster
EXPOSE 3000
