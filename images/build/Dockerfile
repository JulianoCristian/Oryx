FROM buildpack-deps:stable AS main

# Configure locale (required for Python)
ENV LANG C.UTF-8

# Install basic build tools
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        jq \
 && rm -rf /var/lib/apt/lists/*

# Install .NET Core
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        libc6 \
        libcurl3 \
        libgcc1 \
        libgssapi-krb5-2 \
        # libicu52 \ # doesn't exist, but may be needed for .NET Core 1.x
        libicu57 \
        liblttng-ust0 \
        # libssl1.0.0 \ # doesn't exist, but may be needed for .NET Core 1.x
        libssl1.0.2 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        zlib1g \
 && rm -rf /var/lib/apt/lists/*
RUN set -ex \
 && DOTNET_DIR=/opt/dotnet \
 && mkdir -p $DOTNET_DIR \
 # Install .NET Core Runtime 1.0.12
 && DOTNET_VER=1.0.12 \
 && DOTNET_URL=https://dotnetcli.blob.core.windows.net/dotnet/Runtime/$DOTNET_VER/dotnet-debian-x64.$DOTNET_VER.tar.gz \
 && curl -SL $DOTNET_URL | tar -xzf - -C $DOTNET_DIR \
 # Install .NET Core Runtime 1.1.9
 && DOTNET_VER=1.1.9 \
 && DOTNET_URL=https://dotnetcli.blob.core.windows.net/dotnet/Runtime/$DOTNET_VER/dotnet-debian-x64.$DOTNET_VER.tar.gz \
 && curl -SL $DOTNET_URL | tar -xzf - -C $DOTNET_DIR \
 # Install .NET Core Runtime 2.0.9
 && DOTNET_VER=2.0.9 \
 && DOTNET_URL=https://dotnetcli.blob.core.windows.net/dotnet/Runtime/$DOTNET_VER/dotnet-runtime-$DOTNET_VER-linux-x64.tar.gz \
 && DOTNET_SHA=2b49b24ef712fbfc056e0fda95ff18037b4ec938ca8bb41f4c336b6a50870e922f5093684ac92c4bb8e1155b03c36d132d7f90817793f31c9ade5267fff6629a \
 && curl -SL $DOTNET_URL --output dotnet.tar.gz \
 && echo "$DOTNET_SHA dotnet.tar.gz" | sha512sum -c - \
 && tar -xzf dotnet.tar.gz -C $DOTNET_DIR \
 && rm dotnet.tar.gz \
 # Install ASP .NET Core Runtime 2.1.2 (includes .NET Core Runtime 2.1.2)
 && ASPNET_VER=2.1.2 \
 && ASPNET_URL=https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNET_VER/aspnetcore-runtime-$ASPNET_VER-linux-x64.tar.gz \
 && ASPNET_SHA=294a6c256ce7954c05c3dee85d4114e320c7b94b2ae2e854a268b2bb4383a967e1063ee0df0da0f09511b3dc9c215aa735899f5c6db4f11bd58da3cb9cc8b6da \
 && curl -SL $ASPNET_URL --output aspnet.tar.gz \
 && echo "$ASPNET_SHA aspnet.tar.gz" | sha512sum -c - \
 && tar -xzf aspnet.tar.gz -C $DOTNET_DIR \
 && rm aspnet.tar.gz \
 # Install .NET Core SDK 2.1.400
 && DOTNET_SDK_VER=2.1.400 \
 && DOTNET_SDK_URL=https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VER/dotnet-sdk-$DOTNET_SDK_VER-linux-x64.tar.gz \
 && DOTNET_SDK_SHA=9c850fe9d1ac335376fb3ed1f07472d281a9c4ac8ed02cf752ce36c3488d6746c09d6e2101184f3c8de357aae86b567196f4d071b6c55505a250ce6db53ab532 \
 && curl -SL $DOTNET_SDK_URL --output dotnet.tar.gz \
 && echo "$DOTNET_SDK_SHA dotnet.tar.gz" | sha512sum -c - \
 && tar -xzf dotnet.tar.gz -C $DOTNET_DIR \
 && rm dotnet.tar.gz \
 && ln -s $DOTNET_DIR/dotnet /usr/bin/dotnet
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    ASPNETCORE_URLS=http://+:80
RUN dotnet help

# Install Node.js, NPM, Yarn
RUN curl -sL https://git.io/n-install | bash -s -- -ny - \
 && ~/n/bin/n -d 4.4.7 \
 && ~/n/bin/n -d 4.5.0 \
 && ~/n/bin/n -d 6.2.2 \
 && ~/n/bin/n -d 6.6.0 \
 && ~/n/bin/n -d 6.9.3 \
 && ~/n/bin/n -d 6.10.3 \
 && ~/n/bin/n -d 6.11.0 \
 && ~/n/bin/n -d 8.0.0 \
 && ~/n/bin/n -d 8.1.0 \
 && ~/n/bin/n -d 8.2.1 \
 && ~/n/bin/n -d 8.8.1 \
 && ~/n/bin/n -d 8.9.4 \
 && ~/n/bin/n -d 8.11.3 \
 && ~/n/bin/n -d 9.4.0 \
 && ~/n/bin/n -d 10.1.0 \
 && mv /usr/local/n/versions/node /opt/nodejs \
 && rm -rf /usr/local/n ~/n
RUN set -ex \
 && for ver in `ls /opt/nodejs`; do \
        npm_ver=`jq -r .version /opt/nodejs/$ver/lib/node_modules/npm/package.json`; \
        if [ ! -d /opt/npm/$npm_ver ]; then \
            mkdir -p /opt/npm/$npm_ver; \
            ln -s /opt/nodejs/$ver/lib/node_modules /opt/npm/$npm_ver/node_modules; \
            ln -s /opt/nodejs/$ver/lib/node_modules/npm/bin/npm /opt/npm/$npm_ver/npm; \
            if [ -e /opt/nodejs/$ver/lib/node_modules/npm/bin/npx ]; then \
                chmod +x /opt/nodejs/$ver/lib/node_modules/npm/bin/npx; \
                ln -s /opt/nodejs/$ver/lib/node_modules/npm/bin/npx /opt/npm/$npm_ver/npx; \
            fi; \
        fi; \
    done
RUN set -ex \
 && YARN_VERSION=1.9.4 \
 && GPG_KEY=6A010C5166006599AA17F08146C2130DFD2497F5 \
 && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$GPG_KEY" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$GPG_KEY" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$GPG_KEY" \
 && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
 && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
 && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
 && mkdir -p /opt/yarn \
 && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn \
 && mv /opt/yarn/yarn-v$YARN_VERSION /opt/yarn/$YARN_VERSION \
 && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz
RUN set -ex \
 && ln -s 4.5.0 /opt/nodejs/4.5 \
 && ln -s 4.5 /opt/nodejs/4 \
 && ln -s 6.11.0 /opt/nodejs/6.11 \
 && ln -s 6.11 /opt/nodejs/6 \
 && ln -s 8.11.3 /opt/nodejs/lts \
 && ln -s 8.11.3 /opt/nodejs/8.11 \
 && ln -s 8.11 /opt/nodejs/8 \
 && ln -s 9.4.0 /opt/nodejs/9.4 \
 && ln -s 9.4 /opt/nodejs/9 \
 && ln -s 10.1.0 /opt/nodejs/latest \
 && ln -s 10.1.0 /opt/nodejs/10.1 \
 && ln -s 10.1 /opt/nodejs/10
RUN set -ex \
 && ln -s 2.15.9 /opt/npm/2.15 \
 && ln -s 2.15 /opt/npm/2 \
 && ln -s 3.10.10 /opt/npm/3.10 \
 && ln -s 3.10 /opt/npm/3 \
 && ln -s 5.6.0 /opt/npm/latest \
 && ln -s 5.6.0 /opt/npm/5.6 \
 && ln -s 5.6 /opt/npm/5
RUN set -ex \
 && ln -s 1.9.4 /opt/yarn/stable \
 && ln -s 1.9.4 /opt/yarn/latest \
 && ln -s 1.9.4 /opt/yarn/1.9 \
 && ln -s 1.9 /opt/yarn/1
RUN set -ex \
 && cd /usr/local/bin \
 && cp -s /opt/nodejs/lts/bin/* . \
 && cp -s /opt/yarn/stable/bin/yarn /opt/yarn/stable/bin/yarnpkg .

# Install Python prerequisites
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        tk-dev \
        uuid-dev \
 && rm -rf /var/lib/apt/lists/*
# https://github.com/docker-library/python/issues/147
ENV PYTHONIOENCODING UTF-8

# Build Python 2.7.15
FROM buildpack-deps:stable AS python2.7.15-build
WORKDIR /usr/src/python
ENV PYTHON_VERSION=2.7.15
ENV GPG_KEY C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
ENV PIP_VERSION=18.0
COPY python-build.sh /
RUN /python-build.sh

# Build Python 3.5.6
FROM buildpack-deps:stable AS python3.5.6-build
WORKDIR /usr/src/python
ENV PYTHON_VERSION=3.5.6
ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D
ENV PIP_VERSION=18.0
COPY python-build.sh /
RUN /python-build.sh

# Build Python 3.6.6
FROM buildpack-deps:stable AS python3.6.6-build
WORKDIR /usr/src/python
ENV PYTHON_VERSION=3.6.6
ENV GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PIP_VERSION=18.0
COPY python-build.sh /
RUN /python-build.sh

# Build Python 3.7.0
FROM buildpack-deps:stable AS python3.7.0-build
WORKDIR /usr/src/python
ENV PYTHON_VERSION=3.7.0
ENV GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PIP_VERSION=18.0
COPY python-build.sh /
RUN /python-build.sh

# Install Python
FROM main AS python
COPY --from=python2.7.15-build /opt /opt
COPY --from=python3.5.6-build /opt /opt
COPY --from=python3.6.6-build /opt /opt
COPY --from=python3.7.0-build /opt /opt
RUN set -ex \
 && echo /opt/python/2.7.15/lib >> /etc/ld.so.conf.d/python.conf \
 && echo /opt/python/3.5.6/lib >> /etc/ld.so.conf.d/python.conf \
 && echo /opt/python/3.6.6/lib >> /etc/ld.so.conf.d/python.conf \
 && echo /opt/python/3.7.0/lib >> /etc/ld.so.conf.d/python.conf \
 && ldconfig
RUN set -ex \
 && ln -s 2.7.15 /opt/python/2.7 \
 && ln -s 2.7 /opt/python/2 \
 && ln -s 3.5.6 /opt/python/3.5 \
 && ln -s 3.6.6 /opt/python/3.6 \
 && ln -s 3.7.0 /opt/python/latest \
 && ln -s 3.7.0 /opt/python/3.7 \
 && ln -s 3.7 /opt/python/3
RUN set -ex \
 && cd /usr/local/bin \
 && cp -sn /opt/python/2/bin/* . \
 && cp -sn /opt/python/3/bin/* .

FROM python AS final
COPY benv.sh /usr/local/bin/benv
RUN chmod +x /usr/local/bin/benv
ENTRYPOINT [ "benv" ]
CMD [ "bash" ]