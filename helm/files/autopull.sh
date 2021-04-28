#!/bin/bash

set -eo pipefail

echo "check AWS ECR access"
ecr=$(aws ecr get-login  --region "$AWS_REGION"|awk '{print $9}'|cut -d/ -f3)

while true; do

    # ger pairs "pod repo/name sha256" of all containers having latest tag
    kubectl get pods -ojson | \
      jq '.items[] | "pod=" + .metadata.name + (.status.containerStatuses| .[]|select(.image|test("'$ecr'.*:latest$")) | " image=" + (.image|split("/")[1:]|join("/")|split(":")[0]) + " id=" + (.imageID|split(":")[2])) ' -r | \
        while read li; do eval $li
          sha=$(aws ecr list-images --repository-name "$image" --region "$AWS_REGION" | jq '.imageIds[] | select(.imageTag=="latest")|.imageDigest|split(":")[1]' -r)
          echo "inspecting $pod..."
          echo curernt latest image sha256 is "$id" aws sha256 is "$sha"
          if [[ $id != $sha ]]; then
            echo "Restarting pod. ImagePullPolicy should be set to Always..."
            kubectl delete pod "$pod"
          fi
        done
    echo "sleeping..."
    sleep 5
done
