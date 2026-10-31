FROM python:3.12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends git make curl wget xz-utils ca-certificates unzip \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir pillow numpy

WORKDIR /work
ENTRYPOINT ["/work/scripts/tools/generate.sh"]
