set dotenv-load := true

REGISTRY := "regv2.gsingh.io/personal"
IMAGE := "pg-s3-backup"
GIT_TAG := `git tag --sort=-v:refname | head -1`
GIT_COMMIT := `git rev-parse --short HEAD`
GIT_BRANCH := `git rev-parse --abbrev-ref HEAD | sed 's/\//-/g'`
PRIMARY_TAG := if GIT_TAG == "" { GIT_COMMIT } else { GIT_TAG }

build:
    docker build -t {{ REGISTRY }}/{{ IMAGE }}:{{ PRIMARY_TAG }} .

tag: build
    docker tag {{ REGISTRY }}/{{ IMAGE }}:{{ PRIMARY_TAG }} {{ REGISTRY }}/{{ IMAGE }}:latest
    docker tag {{ REGISTRY }}/{{ IMAGE }}:{{ PRIMARY_TAG }} {{ REGISTRY }}/{{ IMAGE }}:{{ GIT_BRANCH }}

push: tag
    docker push {{ REGISTRY }}/{{ IMAGE }}:latest
    docker push {{ REGISTRY }}/{{ IMAGE }}:{{ GIT_BRANCH }}
    docker push {{ REGISTRY }}/{{ IMAGE }}:{{ PRIMARY_TAG }}

release: tag push

all-tags:
    @echo "Git Tag: {{ GIT_TAG }}"
    @echo "Git Commit: {{ GIT_COMMIT }}"
    @echo "Git Branch: {{ GIT_BRANCH }}"
    @echo "Primary Tag: {{ PRIMARY_TAG }}"
    @echo "Tags to push: latest, {{ GIT_BRANCH }}, {{ PRIMARY_TAG }}"
