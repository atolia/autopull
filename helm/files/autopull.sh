#!/bin/bash

set -eo pipefail

echo "Checking AWS ECR access..."
ecr=$(aws ecr get-login --region "$AWS_REGION"|awk '{print $9}'|cut -d/ -f3)
echo "OK.
ATTENTION: ImagePullPolicy should be set to Always to pull image on Pod restart."

doit(){ tag=$1
  # ger pairs "pod repo/name sha256" of all containers having $1 tag
  kubectl get pods -ojson | \
    jq '.items[] | "pod=" + .metadata.name + (.status.containerStatuses| .[]|select(.image|test("'$ecr'.*:'$tag'$")) | " image=" + (.image|split("/")[1:]|join("/")|split(":")[0]) + " id=" + (.imageID|split(":")[2])) ' -r | \
      while read li; do eval $li
        sha=$(aws ecr list-images --repository-name "$image" --region "$AWS_REGION" | \
          jq '.imageIds[] | select(.imageTag=="'$tag'")|.imageDigest|split(":")[1]' -r)
        echo "inspecting $pod..."
        echo "curernt $tag image sha256 is $id aws sha256 is $sha"
        if [[ $id != $sha ]]; then
          echo "Restarting $pod ... " >&2
          kubectl delete pod "$pod"
        fi
      done
}


[ "$DEBUG" != "true" ] && exec > /dev/null

while true; do
  for i in $TAGS; do
    echo "===== $i tag ====="
    doit $i
  done
  echo "sleeping..."
  sleep "$SLEEP"
done
