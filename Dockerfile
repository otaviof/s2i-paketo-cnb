FROM docker.io/paketobuildpacks/builder:full

LABEL \
     io.buildpacks.builder.metadata="" \
     io.k8s.description="S2I Buildpacks" \
     io.k8s.display-name="paketo-buildpacks-full" \
     io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
     io.openshift.tags="builder"

ENV \
     HOME="/workspace" \
     S2I_ARTIFACTS_DIR="/tmp/artifacts" \
     S2I_SRC_DIR="/tmp/src" \
     CNB_USER_ID="1000" \
     CNB_GROUP_ID="1000" \
     CNB_BASE_DIR="/data"

USER 0

COPY ./s2i/bin/ /usr/libexec/s2i

RUN  chown -vR ${CNB_USER_ID}:${CNB_GROUP_ID} /cnb/lifecycle && \
     mkdir -p ${HOME} && \
     chown -v ${CNB_USER_ID}:${CNB_GROUP_ID} ${HOME} && \
     mkdir -p ${CNB_BASE_DIR} && \
     chown -v ${CNB_USER_ID}:${CNB_GROUP_ID} ${CNB_BASE_DIR} && \
     mkdir -p ${S2I_SRC_DIR} && \
     chown -v ${CNB_USER_ID}:${CNB_GROUP_ID} ${S2I_SRC_DIR}

WORKDIR ${HOME}

USER ${CNB_USER_ID}

CMD ["/usr/libexec/s2i/usage"]
