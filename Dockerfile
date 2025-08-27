# 用官方 Dagster 镜像（包含 webserver/daemon 等运行时）
FROM docker.io/dagster/dagster:1.6.17

# 如需在国内构建更快，可开启镜像源（GitHub Actions 通常无需）
# ENV PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple

# 切到 root 安装依赖，再还原为默认用户
USER root

# 必要依赖：本地 JSON Schema 校验 + Kafka 客户端（confluent-kafka）
RUN pip install --no-cache-dir \
      jsonschema==4.22.0 \
      confluent-kafka==2.5.0

# 准备目录与权限（官方镜像里已设置 DAGSTER_HOME，这里稳妥起见再确认）
ENV DAGSTER_HOME=/opt/dagster/dagster_home
RUN mkdir -p /opt/dagster /opt/dagster/dagster_home && \
    chown -R 10101:10101 /opt/dagster

# 还原成镜像默认的非特权用户
USER 10101

WORKDIR /opt/dagster
EXPOSE 3000

# 不在镜像里固定 CMD，继续由 docker-compose 传入：
# 例如：["dagster-webserver","-h","0.0.0.0","-p","3000","-w","/opt/dagster/workspace.yaml"]

# 如你想把代码也打进镜像（可选），解除下面注释，并确保仓库里有这些文件
# COPY workspace.yaml /opt/dagster/workspace.yaml
# COPY app/ /opt/dagster/app/
