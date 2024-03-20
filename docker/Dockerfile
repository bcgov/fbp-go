ARG DOCKER_IMAGE=artifacts.developer.gov.bc.ca/docker-remote/instrumentisto/flutter:3.19


# To build locally, point to a local base image you've already built (see openshift/wps-api-base)
# e.g. : docker build --build-arg DOCKER_IMAGE=wps-api-base:my-tag .

FROM ${DOCKER_IMAGE}

RUN flutter build web

# # PHASE 2 - prepare hosting.
# https://catalog.redhat.com/software/containers/ubi8/nginx-120/6156abfac739c0a4123a86fd
FROM registry.access.redhat.com/ubi8/nginx-120

# Add application sources
ADD ./openshift/nginx.conf "${NGINX_CONF_PATH}"

# Copy the static content:
COPY --from=static /opt/app-root/build/web .

EXPOSE 3000
CMD nginx -g "daemon off;"