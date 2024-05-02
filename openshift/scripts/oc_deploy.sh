#!/bin/sh -l
#
source "$(dirname ${0})/common/common"

#%
#% OpenShift Deploy Helper
#%
#%   Suffixes incl.: test and prod.
#%
#% Usage:
#%
#%   ${THIS_FILE} [SUFFIX] [apply]
#%
#% Examples:
#%
#%   Provide a suffix. Defaults to a dry-run=client.
#%   ${THIS_FILE} test
#%
#%   Apply when satisfied.
#%   ${THIS_FILE} test apply
#%
#%   Override default CPU_REQUEST to 2000 millicores
#%   CPU_REQUEST=2000m ${THIS_FILE} pr-0

# Target project override for Dev or Prod deployments
#
PROJ_TARGET="${PROJ_TARGET:-${PROJ_DEV}}"
OBJ_NAME="${APP_NAME}"
SUFFIX=${1:-}

if [[ "${SUFFIX}" == "prod" ]]; then
    ROUTE_DOMAIN="${VANITY_DOMAIN}"
    PROJ_TARGET="${PROJ_PROD}"
    echo "${ROUTE_DOMAIN}"
else
    PROJ_TARGET="${PROJ_DEV}"
fi
echo "${PROJ_TARGET}"
# Process a template (mostly variable substition)
#
OC_PROCESS="oc -n ${PROJ_TARGET} process -f ${PATH_DEPLOY} \
 -p SUFFIX=${SUFFIX} \
 ${VERSION:+ "-p VERSION=${VERSION}"} \
 ${ROUTE_DOMAIN:+ "-p ROUTE_DOMAIN=${ROUTE_DOMAIN}"} \
 ${PROJ_TOOLS:+ "-p PROJ_TOOLS=${PROJ_TOOLS}"} \
 ${IMAGE_REGISTRY:+ "-p IMAGE_REGISTRY=${IMAGE_REGISTRY}"} \
 ${REPLICAS:+ "-p REPLICAS=${REPLICAS}"}"

# Apply a template (apply or use --dry-run=client)
#
OC_APPLY="oc -n ${PROJ_TARGET} apply -f -"
[ "${APPLY}" ] || OC_APPLY="${OC_APPLY} --dry-run=client"

eval "${OC_PROCESS}"
eval "${OC_PROCESS} | ${OC_APPLY}"