# Docker Desktop WSL CLI Segmentation Fault

Status: resolved on 2026-07-20
Scope: Windows Docker Desktop with Ubuntu 24.04 on WSL 2

## Symptoms

Docker Desktop appeared to be running, but every Docker command in Ubuntu failed before normal output:

~~~text
Segmentation fault
~~~

The Lesson 1 setup stopped with `Docker daemon is unavailable` because its bounded readiness check correctly treated the crashed client as unavailable.

## Evidence and root cause

Evidence collected before changing state:

- The Windows Docker client and server both responded as version 29.6.1.
- Ubuntu `/usr/bin/docker` was a symbolic link to `/mnt/wsl/docker-desktop/cli-tools/usr/bin/docker`.
- The Docker Desktop CLI tools were mounted read-only from an `iso9660` filesystem on WSL `/dev/loop0`.
- Reads of the Docker executable and ELF section headers returned input/output errors.
- WSL kernel messages recorded repeated `/dev/loop0` read failures followed by fatal signals from `docker`.

Root cause: the Docker Desktop WSL integration CLI-tools mount was unhealthy. The Docker CLI crashed while loading its executable, before it could communicate normally with the healthy Docker engine. This was not caused by the lesson Dockerfile, repository path, application container, or insufficient Docker daemon capacity.

## Recovery performed

`[MUTATING — LOCAL DOCKER DESKTOP; TRANSIENT WORKLOAD INTERRUPTION POSSIBLE]`

~~~powershell
docker desktop restart
~~~

This remounted Docker Desktop integration cleanly. A WSL shutdown, package reinstall, Docker factory reset, and data deletion were not required.

## Validation performed

`[READ-ONLY]`

~~~powershell
docker desktop status
docker version --format 'client={{.Client.Version}} server={{.Server.Version}}'
wsl.exe -d Ubuntu-24.04 -- sha256sum /usr/bin/docker
wsl.exe -d Ubuntu-24.04 -- docker --version
wsl.exe -d Ubuntu-24.04 -- docker info --format 'server={{.ServerVersion}}'
wsl.exe -d Ubuntu-24.04 -- docker container ls
~~~

Observed after recovery:

- Docker Desktop status: running.
- Windows client/server: 29.6.1/29.6.1.
- Ubuntu Docker executable became fully readable and hashable.
- Ubuntu Docker client: 29.6.1.
- Ubuntu reached Docker server 29.6.1.
- `docker container ls` completed without a segmentation fault.

## Safe recurrence procedure

1. `[READ-ONLY]` Compare `docker version` on Windows with `docker --version` in Ubuntu.
2. `[READ-ONLY]` Check whether `/usr/bin/docker` points into `/mnt/wsl/docker-desktop/cli-tools` and whether kernel messages show loop-device input/output errors.
3. `[MUTATING]` Restart Docker Desktop and repeat the read-only validation.
4. If the problem persists, save work and close WSL processes before running `[MUTATING]` `wsl --shutdown`, then start Docker Desktop again.
5. If recovery still fails, collect Docker Desktop diagnostics and consider updating WSL or Docker Desktop before reinstalling anything.

Do not begin with Docker factory reset, distribution deletion, broad Docker cleanup, package replacement, or removal of Docker data. Those actions have a larger blast radius and do not follow from this failure evidence.
