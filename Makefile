#
#   Based on Makefile from https://github.com/mvanholsteijn/docker-makefile
#   Based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
#
#
# Import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

RELEASE_SUPPORT := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))/.make-release-support

VERSION=$(shell . $(RELEASE_SUPPORT) ; getVersion)
DOCKER_IMAGE = $(shell . $(RELEASE_SUPPORT) ; getBaseName)
DOCKER_TAGS=$(shell . $(RELEASE_SUPPORT) ; getDockerTags)
TAG=$(shell . $(RELEASE_SUPPORT); getTag)

SHELL=/bin/bash

.PHONY: \
	pre-build docker-build post-build build \
	release patch-prerelease minor-prerelease major-prerelease tag check-status check-release \
	push pre-push do-push post-push \
	changelog

build: pre-build docker-build post-build ## Build one or more docker images

check: pre-build ## Runs several tests (alias for pre-build)

pre-build:

post-build:

pre-push:

post-push:

docker-build:
	@	TAGS=""; \
		for DOCKER_TAG in $(DOCKER_TAGS); do \
		  TAGS=$$TAGS" --tag $(DOCKER_REPO)$(DOCKER_IMAGE):$$DOCKER_TAG"; \
		done; \
		TAGS=$$TAGS" --tag $(DOCKER_REPO)$(DOCKER_IMAGE):latest"; \
		echo "docker build $(DOCKER_BUILD_ARGS) $$TAGS -f $(DOCKER_FILE_PATH) $(DOCKER_BUILD_CONTEXT)"; \
		docker build $(DOCKER_BUILD_ARGS) $$TAGS -f $(DOCKER_FILE_PATH) $(DOCKER_BUILD_CONTEXT)

release: check-status check-release build push

push: pre-push do-push post-push

do-push:
	docker push $(DOCKER_REPO)$(DOCKER_IMAGE)

snapshot: DOCKER_REPO := $(SNAPSHOT_REPO)/
snapshot: build push

tag-new-release: VERSION := $(shell . $(RELEASE_SUPPORT); nextRelease)
tag-new-release: MSG := $(shell . $(RELEASE_SUPPORT); getReleaseMessage)
tag-new-release: changelog tag

tag-new-prerelease: VERSION := $(shell . $(RELEASE_SUPPORT); nextPrerelease)
tag-new-prerelease: MSG := new prerelease
tag-new-prerelease: tag

tag-patch-prerelease: VERSION := $(shell . $(RELEASE_SUPPORT); nextPatchPrerelease)
tag-patch-prerelease: MSG := new patch prerelease
tag-patch-prerelease: tag

tag-minor-prerelease: VERSION := $(shell . $(RELEASE_SUPPORT); nextMinorPrerelease)
tag-minor-prerelease: MSG := new minor prerelease
tag-minor-prerelease: tag

tag-major-prerelease: VERSION := $(shell . $(RELEASE_SUPPORT); nextMajorPrerelease)
tag-major-prerelease: MSG := new major prerelease
tag-major-prerelease: tag

new-release: DOCKER_REPO := $(RELEASE_REPO)/
new-release: tag-new-release release ## Drop the prerelease suffix and release
	@echo $(VERSION)

new-prerelease: DOCKER_REPO := $(PRERELEASE_REPO)/
new-prerelease: tag-new-prerelease release ## Increment the prerelease count and release
	@echo "version $(VERSION) released on $(DOCKER_REPO)"

patch-prerelease: DOCKER_REPO := $(PRERELEASE_REPO)/
patch-prerelease: tag-patch-prerelease release ## Increment the patch version number and release
	@echo "version $(VERSION) released on $(DOCKER_REPO)"

minor-prerelease: DOCKER_REPO := $(PRERELEASE_REPO)/
minor-prerelease: tag-minor-prerelease release ## Increment the minor version number and release
	@echo "version $(VERSION) released on $(DOCKER_REPO)"

major-prerelease: DOCKER_REPO := $(PRERELEASE_REPO)/
major-prerelease: tag-major-prerelease release ## Increment the major version number and release
	@echo "version $(VERSION) released on $(DOCKER_REPO)"

tag: TAG=$(shell . $(RELEASE_SUPPORT); getTag $(VERSION))

tag: check-status ## Check that the tag does not already exist, changes the version in Cargo.toml, commit, and tag.
	@. $(RELEASE_SUPPORT) ; ! tagExists $(TAG) || (echo "ERROR: tag $(TAG) for version $(VERSION) already tagged in git" >&2 && exit 1) ;
	@. $(RELEASE_SUPPORT) ; setRelease $(VERSION)
	cargo check # We need to add this cargo check which will update Cargo.lock. Otherwise Cargo.lock will be modified after,
	            # and the release will seem dirty.
	git add .
	git commit -m "[Versioned] $(MSG) $(VERSION)" ;
	git tag -a $(TAG) -m "Version $(VERSION)";
	@ if [ -n "$(shell git remote -v)" ] ; then git push --tags ; else echo 'no remote to push tags to' ; fi

check-status: ## Check that there are no outstanding changes. (uses git status)
	@. $(RELEASE_SUPPORT) ; ! hasChanges \
		|| (echo "Status ERROR: there are outstanding changes" >&2 && exit 1) \
		&& (echo "Status OK" >&2 ) ;

check-release: TAG=$(shell . $(RELEASE_SUPPORT); getTag $(VERSION))
check-release: ## Check that the current git tag matches the one in Cargo.toml and there are no outstanding changes.
	$(info $$VERSION is [${VERSION}])
	$(info $$TAG is [${TAG}])
	@. $(RELEASE_SUPPORT) ; tagExists $(TAG) || (echo "ERROR: version not yet tagged in git. make [minor,major,patch]-release." >&2 && exit 1) ;
	@. $(RELEASE_SUPPORT) ; ! differsFromRelease $(TAG) || (echo "ERROR: current directory differs from tagged $(TAG). make [minor,major,patch]-release." ; exit 1)

changelog: LAST_TAG := $(shell . $(RELEASE_SUPPORT); getLastTag)
changelog: TAG=$(shell . $(RELEASE_SUPPORT); getTag $(VERSION))
changelog: check-status
	@. $(RELEASE_SUPPORT) ; generateChangelog $(TAG) $(LAST_TAG) ;

######### Debug

check-tag:
	@echo $(TAG)

check-version:
	@echo $(VERSION)
