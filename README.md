# Autopull

Auto pull and restart pod containers if docker images were updated

Auto detect running pods with :latest tag, check sha256 of image with AWS ECR registry. Pull and restart when docker image was updated in registry.
all pods should have `imagePullPolicy: Always`

- `git clone https://github.com/atolia/autopull.git`
- `cd autopull`
- `helm -n <NAMESPACE> update -i autopull helm`

see helm/values.yml for config variables
