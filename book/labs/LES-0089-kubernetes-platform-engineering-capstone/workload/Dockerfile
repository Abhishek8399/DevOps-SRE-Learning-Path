FROM python:3.12.11-slim-bookworm@sha256:519591d6871b7bc437060736b9f7456b8731f1499a57e22e6c285135ae657bf7
ARG SERVICE_UID=10001
ARG SERVICE_GID=10001
RUN groupadd --gid ${SERVICE_GID} service \
    && useradd --uid ${SERVICE_UID} --gid ${SERVICE_GID} --no-log-init --shell /usr/sbin/nologin service
WORKDIR /app
COPY --chown=${SERVICE_UID}:${SERVICE_GID} server.py /app/server.py
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PORT=8080
USER ${SERVICE_UID}:${SERVICE_GID}
EXPOSE 8080
CMD ["python", "/app/server.py"]
