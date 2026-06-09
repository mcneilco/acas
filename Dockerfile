# acas base image.
#
# This is a *base* image: downstream images (acas_custom_schrodinger) and the
# dev docker-compose run `gulp build` / `gulp dev` on top of it, so the Node
# build toolchain (gulp, coffeescript, git) must remain installed here. The
# security-baseline win is the runtime base itself: the former full-distro,
# rolling-tag quay.io/centos/centos:stream9 is replaced by the minimal,
# version-pinned node:20.20.2-slim.
FROM node:20.20.2-slim

# Runtime + build deps (Debian-slim equivalents of the old centos set):
#  - git: required by some npm packages and downstream gulp builds
#  - curl: bin/acas.sh polls the roo persistence service before starting
#  - python3 + pip: the LiveDesign integration scripts the app shells out to
#  - fontconfig + fonts-urw-base35: parity with the old fontconfig/urw-fonts
RUN apt-get update && apt-get install -y --no-install-recommends \
      git tar curl ca-certificates \
      python3 python3-pip \
      fontconfig fonts-urw-base35 \
  && ln -sf /usr/bin/python3 /usr/bin/python \
  && rm -rf /var/lib/apt/lists/*

# Debian marks its Python as externally managed (PEP 668). acas installs the
# LiveDesign ldclient into the user site at runtime (ServerAPI Bootstrap.coffee),
# so allow pip to write there without passing --break-system-packages each call.
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Base python deps used by the runtime LiveDesign scripts. (truststore -- a
# runtime dep of the ldclient that acas installs with --no-deps -- is pinned in
# requirements.txt below, which is the single source for it.)
RUN pip install --no-cache-dir --break-system-packages \
      requests psycopg2-binary

# node:slim ships a `node` user/group at UID/GID 1000; drop it so runner can take 1000.
RUN userdel -r node 2>/dev/null || true; groupdel node 2>/dev/null || true; \
    useradd -u 1000 -ms /bin/bash runner

ENV     APP_NAME=ACAS \
        BUILD_PATH=/home/runner/build \
        ACAS_BASE=/home/runner/acas \
        ACAS_CUSTOM=/home/runner/acas_custom \
        ACAS_SHARED=/home/runner/acas_shared

# forever is intentionally not installed: in a container the runtime
# (Docker/Kubernetes) is the process manager. bin/acas.sh runs node in the
# foreground as PID 1.
RUN     npm install -g gulp@4.0.2 coffeescript@2.5.1
COPY    --chown=runner:runner package.json $ACAS_BASE/package.json
COPY    --chown=runner:runner requirements.txt $ACAS_BASE/requirements.txt
RUN     pip install --no-cache-dir --break-system-packages -r $ACAS_BASE/requirements.txt
USER    runner
WORKDIR $ACAS_BASE

# This installs the modules but not acas, doing this makes subsequent builds much faster so that the container isn't invalidated on a small code change
RUN     npm install --ignore-scripts --loglevel warn
COPY --chown=runner:runner . $ACAS_BASE
RUN     mkdir -p $BUILD_PATH/node_modules && \
        mkdir -p $BUILD_PATH/public && \
        cp -r node_modules $BUILD_PATH && \
        npm install --no-configs && \
        mkdir $BUILD_PATH/privateUploads && \
        mkdir /home/runner/logs && \
        mkdir -p $BUILD_PATH/conf/compiled && \
        rm -rf $ACAS_BASE
WORKDIR $BUILD_PATH
RUN     chmod u+x bin/*.sh
ENV     PREPARE_MODULE_CONF_JSON=true
ENV     PREPARE_CONFIG_FILES=true
ENV     RUN_SYSTEM_TEST=false
ENV     ACAS_HOME=$BUILD_PATH
ARG BUILDTIME=1970-01-01T00:00:00Z
ENV ACAS_CLIENT_ABOUT_ACAS_BUILDTIME=${BUILDTIME}
ARG VERSION=0.0.0
ENV ACAS_CLIENT_ABOUT_ACAS_VERSION=${VERSION}
ARG REVISION=UNKNOWN
ENV ACAS_CLIENT_ABOUT_ACAS_REVISION=${REVISION}
RUN     gulp execute:prepare_config_files

USER	runner

EXPOSE 3000
CMD     ["bin/acas.sh", "run"]
