set dotenv-load := true

REGISTRY := "regv2.gsingh.io"
IMAGE := "pg-s3-backup"
TAG := "latest"

default:
    @just --list

build:
    docker build -t {{ REGISTRY }}/{{ IMAGE }}:{{ TAG }} .

push: build
    docker push {{ REGISTRY }}/{{ IMAGE }}:{{ TAG }}

tag-latest: build
    docker tag {{ REGISTRY }}/{{ IMAGE }}:{{ TAG }} {{ REGISTRY }}/{{ IMAGE }}:latest

release: tag-latest push
    echo "Image {{ REGISTRY }}/{{ IMAGE }}:{{ TAG }} published successfully"
