`s2i-paketo-cnb`
----------------

This project is a proof-of-concept (PoC) to show a regular [`s2i` builder-image][s2iBuilderImage] for [buildpacks][buildpacksIO] ([Paketo][paketoBuildpacks]), the builder follows the regular [s2i workflow][s2iBuilderWorkflow] while performing the [buildpacks' lifecycle][buildpacksLifecycle] on the [`assemble` script](s2i/bin/assemble).

The objective of this PoC is providing to the Red Hat customers a practical way of consuming [`buildpacks`][buildpacksIO] while using their existing `s2i` based automation, including OpenShift Builds.

# Challenges

Trying to accommodate `s2i` and buildpacks together presents a few challenges, as one would expect. Lets explain the challenges in the next topics.

## Label Limit Size

Buildpacks requires a number of labels to identify its contents, as in which buildpacks are part of the CNB image, also configuration and metadata in general. However, this information is encoded as JSON and is, most of the times, [longer than `s2i` is willing to accept][s2iLabelLimit].

However, that's relatively simple modification to the project in order to access longer labels when dealing with buildpack CNBs.

## External Image Builder

Following [the `s2i` workflow][s2iWorkflow], it will manage all actions to build a new container image up to the commmit, hence `s2i` instructs Docker to save the image as final.

In other hand, buildpacks' CNB is designed to do the same, more specifically [using the `exporter`][cnbExporter], a [component responsible][cnbExporterLifecycle] for reading the data produced by the previous steps, and consist all layers into a new container image. Something that can be performed directly against a Container Registry or using a docker-socket.

In other words, the modifications we need in `s2i` are related to delegate to the (buildpacks)builder-image the responsibility of pushing the final image, avoiding `s2i` from trying to `commit` at the end. Additionally, `s2i` could verify the image produced.

By delegating this responsibility to the builder it also implies sharing the container registry credentials, or sharing access to the docker-socket.

### Runtime-Image vs. Buildpacks' Rebase

Source-to-Image has the ability to [rely on a `--runtime-image`][s2iRuntimeImage] as a type of *multi-stage build*, data generated by the `assemble` script can be copied (`--runtime-artifact`) to the final container image committed by `s2i`.

Buildpacks brings the concept of [image "rebase"][buildpacksImageRebase], by identifying the base layer (`FROM`) and replacying with another, effectively restacking the other subsequent layers on a new container image. By only manipulating layers rebasing is a lot more cost effective than a full image rebuild.

By moving forward supporting buildpacks on `s2i` we need to make sure the `--runtime-image` becomes a interface to buildpacks image rebase.

### OpenShift As-Dockerfile

The same challenge happens in OpenShift Builds using `--as-dockerfile` flag. The `Dockerfile` produced will attempt to `export` the image as well.

Therefore on OpenShift we need to consider the `Dockerfile` generated by `s2i` acts initially as a "Job", since it runs a process to assemble a new container image, later the image produced by this `Dockerfile` is useful for [incremental builds][s2iIncrementalBuilds], caching out the data downloaded by buildpacks.

# Usage

## Building

To build this project container image just use `make`, and please consider the variables you can overwrite to use another Container Registry. For instance:

```bash
make build push IMAGE_REPO=otaviof IMAGE_NAME=s2i-paketo-cnb
```

## Testing

Before running `s2i`, make sure you're [using the changes in `buildpacks` branch][s2iBuildpacksFork]:

```bash
git clone --branch=buildpacks https://github.com/otaviof/source-to-image.git
```

Next, build and install the executable, the example below shows the usual Golang approach on a Linux `amd54` host, might need adjustments to work on your worksation:

```bash
make && install --mode=0755 _output/local/bin/linux/amd64/s2i ${GOPATH}/bin/
```

Testing this s2i builder is done using a example buildpacks compatible repository, in this example [ `otaviof/typescript-ex`][otaviofTypescriptEX] and the builder image as next `s2i` argument, i.e:

```bash
s2i build \
	https://github.com/otaviof/typescript-ex.git \
	ghcr.io/otaviof/s2i-paketo-cnb:latest \
	ghcr.io/otaviof/typescript-ex:latest

```

[buildpacksImageRebase]: https://buildpacks.io/docs/concepts/operations/rebase/
[buildpacksIO]: https://buildpacks.io/
[cnbExporter]: https://github.com/buildpacks/lifecycle/blob/1398dfa30c60f9a9945abe940c72532b518aa191/exporter.go
[cnbExporterLifecycle]: https://buildpacks.io/docs/concepts/components/lifecycle/export/
[otaviofTypescriptEX]: https://github.com/otaviof/typescript-ex.git
[paketoBuildpacks]: https://github.com/paketo-buildpacks
[s2iBuilderImage]: https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md
[s2iBuildpacksFork]: https://github.com/otaviof/source-to-image/tree/buildpacks
[s2iIncrementalBuilds]: https://docs.openshift.com/container-platform/4.12/cicd/builds/build-strategies.html#builds-strategy-s2i-incremental-builds_build-strategies-docker
[s2iLabelLimit]: https://github.com/openshift/source-to-image/blob/78363eee76a5c52f23df3bbffb4e2e8393b4a043/pkg/build/strategies/sti/postexecutorstep.go#L132-L134
[s2iWorkflow]: https://github.com/openshift/source-to-image/blob/78363eee76a5c52f23df3bbffb4e2e8393b4a043/docs/sti-flow.png
