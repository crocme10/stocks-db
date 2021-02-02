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
# docker build --tag="${DOCKER_REPO}/${PROJECT}" -f docker/Dockerfile .
# docker push ${DOCKER_REPO}/${PROJECT}
cmd="docker run -d -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=${POSTGRES_DB} -p 5432:5432/tcp --name ${DOCKER_NAME} ${DOCKER_REPO}/${PROJECT}:${VERSION}"
echo "$cmd"
eval "$cmd"
docker logs -f ${DOCKER_NAME}
