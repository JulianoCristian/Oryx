# Build PHP 7.2
FROM php-build-prereqs AS php72-build
RUN set -eux && . /php/__php-versions.sh && PHP_VERSION=$PHP72_VERSION GPG_KEYS=$PHP72_KEYS PHP_SHA256=$PHP72_TAR_SHA256 /php/build.sh
