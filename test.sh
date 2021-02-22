#!/bin/bash

source deploy.env
PROJECT=db
DOCKER_NAME=stocks-db
VERSION=$(cat ./version)
POSTGRES_DB=stocks

if docker ps --all | grep -q ${DOCKER_NAME}; then
  docker stop ${DOCKER_NAME}
  docker rm ${DOCKER_NAME}
fi
docker build --tag="${SNAPSHOT_REPO}/${PROJECT}:${VERSION}" -f docker/Dockerfile .
docker push ${SNAPSHOT_REPO}/${PROJECT}:${VERSION}
cmd="docker run -d -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=${POSTGRES_DB} -p 5432:5432/tcp --name ${DOCKER_NAME} ${SNAPSHOT_REPO}/${PROJECT}:${VERSION}"
echo "$cmd"
eval "$cmd"

docker logs -f ${DOCKER_NAME}
