#!/bin/sh
echo 'only one at a time'

sudo apt-get install curl jq cut grep -y

#This variable needs to be set in the build and look like:
#CIRCLE_BUILD_URL="https://circleci.com/gh/fernfernfern/jest-puppeteer-example/6"

NEXT_BUILD_DONE=0
export OOATS_VCS_TYPE=$(echo $CIRCLE_BUILD_URL | grep / | cut -d/ -f4-6 | cut -d/ -f1)
export OOATS_USERNAME=$(echo $CIRCLE_BUILD_URL | grep / | cut -d/ -f4-6 | cut -d/ -f2)
export OOATS_PROJECT=$(echo $CIRCLE_BUILD_URL | grep / | cut -d/ -f4-6 | cut -d/ -f3)

if [[ $OOATS_VCS_TYPE == 'gh' ]] ; then 
    export OOATS_VCS_TYPE=github 
fi

if [[ $OOATS_VCS_TYPE == 'bb' ]] ; then 
    export OOATS_VCS_TYPE=bitbucket 
fi

until [ $NEXT_BUILD_DONE -eq 1];
do
    BUILDS=$(curl -u ${OOATS_API_KEY}: https://circleci.com/api/v1.1/project/${OOATS_VCS_TYPE}/${OOATS_USERNAME}/${OOATS_PROJECT})

    $BUILDS | jq -c -r ".[] | {build_num: .build_num, status: .status}"

    sleep 10;
done;
echo 'Ready!';