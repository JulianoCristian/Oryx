# Startup script generator
FROM golang:1.11-stretch as startupCmdGen
WORKDIR /go/src/startupscriptgenerator/
COPY src/startupscriptgenerator .
ARG GIT_COMMIT=unspecified
ARG BUILD_NUMBER=unspecified
ENV GIT_COMMIT=${GIT_COMMIT}
ENV BUILD_NUMBER=${BUILD_NUMBER}
RUN ./build.sh node /opt/startupcmdgen/startupcmdgen

# The official Node 8.2 image has vulnerabilities, so we build our own version
# to fetch the latest strech release with the required fixes.
# https://github.com/nodejs/docker-node.git, commit ID 9b863beddf7dee9b8a6eba0dd8334b1d7980f958.
FROM buildpack-deps:stretch as node-original-image

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
      for i in {1..5}; do \
        gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
        gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key"; \
        if [ $? -eq 0 ]; then break; fi \
      done; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 8.2.1

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 0.27.5

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
      for i in {1..5}; do \
        gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
        gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key"; \
        if [ $? -eq 0 ]; then break; fi \
      done; \
  done \
  && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt/yarn \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn --strip-components=1 \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

CMD [ "node" ]

FROM node-original-image as oryx

RUN  if command -v apt-get; then \
       apt-get update && apt-get upgrade --yes; \
     fi;

# Bake Application Insights key from pipeline variable into final image
ARG AI_KEY
ENV ORYX_AI_INSTRUMENTATION_KEY=${AI_KEY}

# All users need access to node_modules at the root, as this is the location
# for packages valid for all apps.
RUN mkdir -p /node_modules \
 && chmod 777 /node_modules

COPY --from=startupCmdGen /opt/startupcmdgen/startupcmdgen /opt/startupcmdgen/startupcmdgen
RUN ln -s /opt/startupcmdgen/startupcmdgen /usr/local/bin/oryx