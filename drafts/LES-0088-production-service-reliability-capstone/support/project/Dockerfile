# syntax=docker/dockerfile:1
FROM python:3.12.11-slim-bookworm@sha256:519591d6871b7bc437060736b9f7456b8731f1499a57e22e6c285135ae657bf7

ARG SERVICE_UID=10001
ARG SERVICE_GID=10001
RUN groupadd --gid ${SERVICE_GID} atlas \
    && useradd --uid ${SERVICE_UID} --gid ${SERVICE_GID} --no-log-init --shell /usr/sbin/nologin atlas \
    && install -d -o ${SERVICE_UID} -g ${SERVICE_GID} /app /var/lib/atlas

WORKDIR /app
COPY --chown=${SERVICE_UID}:${SERVICE_GID} service/ /app/service/
COPY --chown=${SERVICE_UID}:${SERVICE_GID} pyproject.toml /app/pyproject.toml

ENV PYTHONPATH=/app/service \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    ATLAS_BIND=0.0.0.0 \
    ATLAS_ALLOW_NON_LOOPBACK=true \
    ATLAS_PORT=8080 \
    ATLAS_DB_PATH=/var/lib/atlas/atlas.db

USER ${SERVICE_UID}:${SERVICE_GID}
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=2s --start-period=5s --retries=3 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/readyz', timeout=1).read()"]
CMD ["python", "-m", "atlas_service"]
