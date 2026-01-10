FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    postgresql-client \
    awscli \
    gzip \
    bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app

COPY scripts/pg_s3_backup /app/pg_s3_backup

RUN chmod +x /app/pg_s3_backup

WORKDIR /app

ENTRYPOINT ["/app/pg_s3_backup"]
