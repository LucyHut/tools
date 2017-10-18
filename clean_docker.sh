#!/bin/sh

echo "List of all exited containers:"
echo "cmd: docker ps -aq -f status=exited"
docker ps -aq -f status=exited

echo "Remove stopped containers:"
echo "cmd: docker ps -aq --no-trunc | xargs docker rm"
docker ps -aq --no-trunc | xargs docker rm

#This command will not remove running containers, 
#only an error message will be printed out for each of them.

echo "Remove dangling/untagged images:"
echo "cmd: docker images -q --filter dangling=true | xargs docker rmi"
docker images -q --filter dangling=true | xargs docker rmi
