#syntax=docker/dockerfile:1.2

FROM elixir:1.11-alpine AS backend
RUN apk update && apk add git gcc g++ musl-dev make cmake file-dev
COPY pleroma /work
ENV MIX_ENV=prod
RUN --mount=type=cache,target=/work/deps,sharing=private \
    --mount=type=cache,target=/work/_build,sharing=private \
    --mount=type=cache,target=/root/.mix \
    cd /work && \
    echo "import Mix.Config" > config/prod.secret.exs && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod && \
    mkdir release && \
    mix release --path release

FROM azyobuzin/s3wf2port AS s3wf2port

FROM alpine:3.13 AS pleroma
RUN apk update && apk add exiftool ffmpeg imagemagick libmagic ncurses postgresql-client
ARG HOME=/opt/pleroma
ARG DATA=/var/lib/pleroma
RUN adduser --system --shell /bin/false --home ${HOME} pleroma &&\
    mkdir -p ${DATA}/uploads &&\
    mkdir -p ${DATA}/static &&\
    chown -R pleroma ${DATA} &&\
    mkdir -p /etc/pleroma &&\
    chown -R pleroma /etc/pleroma
USER pleroma
COPY --from=backend --chown=pleroma:0 /work/release ${HOME}
COPY pleroma/config/docker.exs /etc/pleroma/config.exs
COPY pleroma/docker-entrypoint.sh ${HOME}
COPY --from=s3wf2port /usr/local/bin/s3wf2port /usr/local/bin/s3wf2port
COPY --chown=pleroma:0 fe/ /var/lib/pleroma/static/
EXPOSE 4000
ENTRYPOINT ["/opt/pleroma/docker-entrypoint.sh"]
LABEL org.opencontainers.image.authors="azyobuzin <azyobuzin@users.sourceforge.jp>" \
      org.opencontainers.image.source=https://github.com/azyobuzin/xxx-workflow
