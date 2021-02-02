#!/bin/bash

source deploy.env
PROJECT=stocks-db
VERSION=$(cat ./version)
POSTGRES_DB=stocks

if docker ps --all | grep -q ${PROJECT}; then
  docker stop ${PROJECT}
  docker rm ${PROJECT}
fi
# docker build --tag="${DOCKER_REPO}/${PROJECT}" -f docker/Dockerfile .
# docker push ${DOCKER_REPO}/${PROJECT}
docker run -d -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=${POSTGRES_DB} -p 5432:5432/tcp --name ${PROJECT} ${DOCKER_REPO}/${PROJECT}:${VERSION}
docker logs -f ${PROJECT}
