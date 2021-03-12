FROM azyobuzin/s3wf2port AS s3wf2port
FROM xxx-be
COPY --chown=pleroma:0 fe/ /var/lib/pleroma/static/
COPY --from=s3wf2port /usr/local/bin/s3wf2port /usr/local/bin/s3wf2port
LABEL org.opencontainers.image.authors="azyobuzin <azyobuzin@users.sourceforge.jp>" \
      org.opencontainers.image.source=https://github.com/azyobuzin/xxx-workflow
