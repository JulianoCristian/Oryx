#!/bin/bash
# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.
# --------------------------------------------------------------------------------------------

declare -r BUILD_NUMBER="$BUILD_BUILDNUMBER"
declare -r DOCKER_SYSTEM_PRUNE="${ORYX_DOCKER_SYSTEM_PRUNE:-false}"

echo
echo "Kill all running containers and delete all stopped containers"
echo
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)

function UntagImages() {
	local imagePattern=$1
	local imagesToUntag=$(docker images --filter=reference="$imagePattern" --format "{{.Repository}}:{{.Tag}}")

	echo
	echo "Found following images having the pattern '$imagePattern'. Untagging them ..."
	echo $imagesToUntag
	echo

	if [ ! -z "$imagesToUntag" ]
	then
		docker rmi -f $imagesToUntag
	fi
}

echo
echo "Current list of docker images:"
echo
docker images

# An image that is built in our pipelines is tagged with 'latest' and 'build number'.
# The following is to untag an image with the 'build number' tag so that when the next time
# images are built, the older images can become dangled which can later be cleaned up.
#
# **NOTE**
# - We still keep the tags of the following pattern because we still need some cache so that next builds are faster
#	a. oryxdevms/build:latest
#	b. oryxdevms/python-<major.minor>:latest
#	b. oryxdevms/node-<major.minor>:latest
#	b. oryxdevms/dotnetcore-<major.minor>:latest
# - We should untag these images only after they have been pushed to a remote repository.
UntagImages "oryxdevms/*:*.*"
UntagImages "oryxtests/*:latest"
UntagImages "oryxprod/*:latest"
UntagImages "oryxprod/*:*.*"
UntagImages "oryxdevmcr.azurecr.io/public/oryx/*:latest"
UntagImages "oryxdevmcr.azurecr.io/public/oryx/*:*.*"
UntagImages "oryxmcr.azurecr.io/public/oryx/*:latest"
UntagImages "oryxmcr.azurecr.io/public/oryx/*:*.*"

echo
echo "Updated list of docker images:"
echo
docker images

echo
echo "Cleanup: Run 'docker system prune': $DOCKER_SYSTEM_PRUNE"
if [ "$DOCKER_SYSTEM_PRUNE" == "true" ]
then
    docker system prune -f

    echo
    echo "Updated list of docker images:"
    echo
    docker images
fi