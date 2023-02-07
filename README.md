`s2i-paketo-cnb`
----------------

This project is a proof-of-concept (PoC) to show a regular [`s2i` builder image][s2iBuilderImage] using [buildpacks][buildpacks], the builder follows the regular [s2i workflow][s2iBuilderWorkflow] while performing the [buildpacks' lifecycle][buildpacksLifecycle] in the background.

The objective of this PoC is providing Red Hat customers a elegant way of consuming buildpacks while their existing `s2i` based automation.

# Challenges

Trying to accommodate `s2i` and buildpacks together presents a few challenges, as one would expect. Lets explain the challenges in the next topics.

## Label Limit Size

Buildpacks requires a number of labels to identify its contents, as in which buildpacks are part of the CNB image, also configuration and metadata in general. However, this information is encoded as JSON and is, most of the times, [longer than `s2i` is willing to accept][s2iLabelLimit].

However, that's relatively simple modification to the project in order to access longer labels when dealing with buildpack CNBs.

## Delegate Image Builder

Following the `s2i` workflow, it will manage all actions to build a new container image up to the commmit, hence `s2i` instructs Docker to save the image as final.

In other hand, buildpacks' CNB is designed to do the same, more specifically [using the `exporter`][cnbExporter], a [component responsible][cnbExporterLifecycle] for reading the data produced by the previous steps, and consist all layers into a new container image. Something that can be done against a Container Registry directly or using the docker-socket.

In other words, the modifications we need in `s2i` are related to delegate to the builder image the responsibility of pushing the final image, avoiding `s2i` from trying to `commit` at the end. Additionally, `s2i` could verify the image produced.

By delegating this responsibility to the builder it also implies sharing the container registry credentials, or sharing access with the docker-socket. Something we strive to avoid.

### OpenShift As-Dockerfile

The same challenge happens in OpenShift Builds using `--as-dockerfile` flag. The `Dockerfile` produced will attempt to `export` the image as well.

# Usage

## Building

To build this project container image just use `make`, and please consider the variables you can overwrite in order to use your own registry.

```bash
make build push IMAGE_TAG=latest
```

## Testing

Testing this s2i builder is done using a example buildpacks compatible repository, in this example [ `otaviof/typescript-ex`][otaviofTypescriptEX] and the builder image as next `s2i` argument, i.e:


```bash
s2i build \
	https://github.com/otaviof/typescript-ex.git \
	ghcr.io/otaviof/s2i-paketo-cnb:latest \
	ghcr.io/otaviof/typescript-ex:latest

```

[otaviofTypescriptEX]: https://github.com/otaviof/typescript-ex.git
[s2iBuilderImage]: https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md
[s2iLabelLimit]: https://github.com/openshift/source-to-image/blob/78363eee76a5c52f23df3bbffb4e2e8393b4a043/pkg/build/strategies/sti/postexecutorstep.go#L132-L134
[cnbExporter]: https://github.com/buildpacks/lifecycle/blob/1398dfa30c60f9a9945abe940c72532b518aa191/exporter.go
[cnbExporterLifecycle]: https://buildpacks.io/docs/concepts/components/lifecycle/export/
