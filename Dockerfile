FROM debian:bookworm-slim

# Install prerequisites for PostgreSQL repository
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add PostgreSQL official repository for latest client version
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL 18 client and other dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client-18 \
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
