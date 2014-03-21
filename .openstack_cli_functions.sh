#
# This file has overrides for the following commands:
# - trove
#
OPENSTACK_CLI_PATH=/usr/local/bin

#
# trove needs the service-type to be set to rax:database in order to work
# with rackspace cloud database servers. It can be overriden with the
# additional --service-type specified.
#
trove() {
    if [ -z $OS_SERVICE_TYPE ] && [ $# -ne 0 ]
    then
        SERVICE_TYPE="--service-type rax:database"
    else
        SERVICE_TYPE=""
    fi
    ${OPENSTACK_CLI_PATH}/trove ${SERVICE_TYPE} $*
}

region() {
    export OS_REGION_NAME=$1
    export HEAT_URL=https://$(echo ${OS_REGION_NAME} | tr '[:upper:]' '[:lower:]').orchestration.api.rackspacecloud.com/v1/${HEAT_TENANT_ID}
}
