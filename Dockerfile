# Dockerfile for running role linting and Molecule from a clean image.

ARG BASE_IMAGE=python:3.13-slim
ARG VENV_PATH=/opt/venv

FROM ${BASE_IMAGE} AS builder

ARG VENV_PATH
WORKDIR /build

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY pyproject.toml ./

RUN set -o nounset -o errexit -o xtrace \
    && UV_PROJECT_ENVIRONMENT=${VENV_PATH} uv sync --extra dev --no-install-project \
    && true

FROM ${BASE_IMAGE} AS final

ARG VENV_PATH
WORKDIR /work

ENV VIRTUAL_ENV=${VENV_PATH} \
    PYTHONUNBUFFERED=1 \
    PATH="${VENV_PATH}/bin:${PATH}"

RUN set -o nounset -o errexit -o xtrace \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        git \
        openssh-client \
        rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder ${VENV_PATH} ${VENV_PATH}

CMD ["ansible", "--version"]
