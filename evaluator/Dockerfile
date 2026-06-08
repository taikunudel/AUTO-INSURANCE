FROM rocker/r-ver:4.5.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev libssl-dev libxml2-dev libsodium-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('plumber','jsonlite','yaml','cplm'), repos='https://cloud.r-project.org')"

WORKDIR /opt/eval-api
COPY app.R ./
COPY datasets/ ./datasets/

ENV EVAL_DATASETS_DIR=/opt/eval-api/datasets \
    EVAL_SECRET_DIR=/opt/eval-api/secrets \
    EVAL_LOG_PATH=/opt/eval-api/logs/submissions.jsonl \
    EVAL_ADMIN_TOKEN= \
    PORT=8000 \
    HOST=0.0.0.0

# EVAL_ADMIN_TOKEN must be supplied at runtime, e.g.:
#   docker run -e EVAL_ADMIN_TOKEN=$(openssl rand -hex 32) -p 8765:8000 ...

EXPOSE 8000
CMD ["Rscript", "app.R"]
