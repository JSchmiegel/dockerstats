/bin/sh

curl -s --unix-socket /var/run/docker.sock http/containers/json > temp.json
chmod 770 ./temp.json
for item in $(cat ./temp.json | jq -r '.[] | .Id')
do
 curl -s --unix-socket /var/run/docker.sock http/containers/${item}/stats?stream=false
done
