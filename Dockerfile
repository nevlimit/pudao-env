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

EXPOSE 3000
