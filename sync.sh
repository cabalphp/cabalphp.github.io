#!/bin/bash
scriptDir="$( cd "$( dirname "$0"  )" && pwd  )"

fswatch $scriptDir -e sync.sh | while read file
do
    rsync -avzP -e ssh --exclude=sync.sh $scriptDir/  root@119.28.136.181:/www/wwwroot/cabalphp.com/
    echo "${file} was changed start sync..."
done

