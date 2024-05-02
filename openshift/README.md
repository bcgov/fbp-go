# Flutter web build config

Uses flutter image packaged here: https://hub.docker.com/r/instrumentisto/flutter

## Building

### Apply template to build the base image on Openshift

```bash
oc -n e1e498-tools process -f build.yaml | oc -n e1e498-tools apply -f -
```

### Apply template using a specified branch and version

```bash
oc -n e1e498-tools -p VERSION=some-date -p GIT_BRANCH=my-branch process -f openshift/templates/build.yaml | oc -n e1e498-tools apply -f -
```

### Kick off the build

```bash
oc -n e1e498-tools start-build fbp-go --follow
```

### Deploy

Deploy using bash script with the "Version" of ImageStreamTag and specifying test/prod as a suffix. 'test' deploys to dev, 'prod' deploys to prod

```bash
VERSION="may-2-2024" bash openshift/scripts/oc_deploy.sh test apply
```

### TODO Re-tag for production

Assuming you've built an image tagged for dev, you may now want to tag it for production. Remember to retain
the current prod image in case you want to revert!

You may also want to delete any old tags that are no longer relevant.

```bash
# maybe tag the current production image in case we need to revert
oc -n e1e498-tools tag s3-backup:prod s3-backup:previous-prod
# tag this image with something useful, may todays date
oc -n e1e498-tools tag s3-backup:dev s3-backup:some-sensible-tag-like-the-current-date
# tag it for production
oc -n e1e498-tools tag s3-backup:dev s3-backup:prod
```
