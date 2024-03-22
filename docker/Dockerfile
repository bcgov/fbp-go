ARG DOCKER_IMAGE=artifacts.developer.gov.bc.ca/docker-remote/instrumentisto/flutter:3.19

# To build locally, point to a local base image you've already built (see openshift/wps-api-base)
# e.g. : docker build --build-arg DOCKER_IMAGE=wps-api-base:my-tag .

FROM ${DOCKER_IMAGE} as static

WORKDIR /opt/app-root/fbp-go/

# Copy app files from repo
COPY ./pubspec.lock /opt/app-root/fbp-go/

RUN flutter build web

# # PHASE 2 - prepare hosting.
# https://catalog.redhat.com/software/containers/ubi8/nginx-122/627245493b950f9f4eb01218?architecture=amd64&image=65cba48e6e4e02d0baaab056&container-tabs=overview
FROM registry.access.redhat.com/ubi8/nginx-122:1-55

# Add application sources
ADD ./openshift/nginx.conf "${NGINX_CONF_PATH}"

# Copy the static content:
COPY --from=static /opt/app-root/fbp-go/build/web .

EXPOSE 3000
CMD nginx -g "daemon off;"