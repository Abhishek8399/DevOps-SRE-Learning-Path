FROM busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662

LABEL org.opencontainers.image.title="DevOps/SRE Phase 1 ENOSPC Lab"
LABEL org.opencontainers.image.version="1"
LABEL devops-sre.training="phase01-lesson01-image"

COPY --chmod=0555 internal/inject-incident.sh /usr/local/bin/inject-incident

ENTRYPOINT ["/usr/local/bin/inject-incident"]
