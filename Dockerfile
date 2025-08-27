FROM python:3.10-slim

ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DAGSTER_HOME=/opt/dagster/dagster_home

# 安装 Dagster（Web UI + Daemon）及常用集成
RUN apt-get update && apt-get install -y --no-install-recommends gcc build-essential \
 && pip install "dagster==1.11.7" "dagster-webserver==1.11.7" \
               dagster-postgres dagster-docker \
 && apt-get purge -y gcc build-essential && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $DAGSTER_HOME
WORKDIR /opt/dagster

# 你现有的 Dockerfile 里补一行
RUN pip install --no-cache-dir kafka-python==2.0.2

# 你当前用的基础镜像版本（保持和 compose 里一致）
FROM docker.io/dagster/dagster:1.11.7

# 如镜像使用非root用户，先切回 root 安装，然后还原
USER root

# 安装我们代码需要的依赖
RUN pip install --no-cache-dir \
      jsonschema==4.22.0 \
      confluent-kafka==2.5.0

# 还原成镜像默认用户（官方 dagster 镜像常用 10101）
USER 10101



EXPOSE 3000
