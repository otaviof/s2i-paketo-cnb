# fully qualifiyed image name components
IMAGE_BASE ?= ghcr.io
IMAGE_REPO ?= otaviof
IMAGE_NAME ?= s2i-paketo-cnb
IMAGE_TAG ?= latest

FQIN = $(IMAGE_BASE)/$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

default: build

# builds the container image adding labels to link the image with a GitHub repository
.PHONY: build
build:
	docker build \
		--tag=$(FQIN) \
		--label="org.opencontainers.image.source=https://github.com/$(IMAGE_REPO)/$(IMAGE_NAME)" \
		--label "org.opencontainers.image.description=S2I Builder for Buildpacks Lifecycle" \
		--label "org.opencontainers.image.licenses=Apache-2.0" \
		.

# pushes the image
.PHONY: push
push:
	docker push $(FQIN)
