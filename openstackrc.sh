#!/bin/bash -x

# With the addition of Keystone, to use an openstack cloud you should
# authenticate against keystone, which returns a **Token** and **Service
# Catalog**.  The catalog contains the endpoint for all services the
# user/tenant has access to - including nova, glance, keystone, swift.
#
# *NOTE*: Using the 2.0 *auth api* does not mean that compute api is 2.0.  We
# will use the 1.1 *compute api*
export OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0

# OS_TENANT_ID is left blank on purpose because it interferes with swift client
# in rackspace public. If you have a openstack implementation you should set the tenant
# id.
# working.
export OS_TENANT_ID=" "
# export OS_TENANT_NAME="service"
export OS_TENANT_NAME=" "

# In addition to the owning entity (tenant), openstack stores the entity
# performing the action as the **user**.
echo -n "Please enter your Openstack Username: "
read OS_USERNAME
export OS_USERNAME=$OS_USERNAME

# With Keystone you pass the keystone password.
echo -n "Please enter your OpenStack Password: "
read -s OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT
echo

# os-region-name
echo -n "Please enter your Region (ORD, DFW, IAD, SYD): "
read OS_REGION_NAME
export OS_REGION_NAME_UPPER=$(echo $OS_REGION_NAME | tr '[:lower:]' '[:upper:]')
export OS_REGION_NAME_LOWER=$(echo $OS_REGION_NAME | tr '[:upper:]' '[:lower:]')

# HEAT Tenant ID, needed to make this work.
echo -n "Please enter HEAT tenant ID (Rackspace Account ID): "
read HEAT_TENANT_ID
export HEAT_TENANT_ID=${HEAT_TENANT_ID}
# export HEAT_URL=https://api.rs-heat.com/v1/${HEAT_TENANT_ID}/
export HEAT_URL=https://$(echo ${OS_REGION_NAME} | tr '[:upper:]' '[:lower:]').orchestration.api.rackspacecloud.com/v1/${HEAT_TENANT_ID}

#
# Setup clb cache file for Cloud Load Balancers
#
export CLOUD_SERVERS_USERNAME=$OS_USERNAME
export CLOUD_SERVERS_API_TOKEN=$(keystone token-get 2>/dev/null | egrep ' id ' | awk '{print $4}')
export CLOUD_SERVERS_API_KEY=$CLOUD_SERVERS_API_TOKEN
export CLOUD_LOADBALANCERS_REGION=$OS_REGION_NAME_UPPER

#
# Each time this file is sourced recreate clb configuration and API token
#
cat <<EOF > .clb-lastconnection
[connection]
username = $OS_USERNAME
authtoken = $(keystone token-get 2>/dev/null | egrep ' id ' | awk '{print $4}')
regionurl = https://${OS_REGION_NAME_LOWER}.loadbalancers.api.rackspacecloud.com/v1.0/${HEAT_TENANT_ID}
timestamp = $(date +"%Y-%m-%d %H:%M:%S")
EOF

#
# Setup API Key
#
export OS_TOKEN=$CLOUD_SERVERS_API_TOKEN
export USERID=$(keystone token-get 2>/dev/null | grep user_id | awk '{print $4}')
export OS_KEY=$(curl -s ${OS_AUTH_URL}/users/${USERID}/OS-KSADM/credentials/RAX-KSKEY:apiKeyCredentials -H "Content-Type: application/json" -H "X-Auth-Token: $OS_TOKEN" | python -m json.tool | python -c "import json;import sys;print '%s' % json.loads(sys.stdin.read())['RAX-KSKEY:apiKeyCredentials']['apiKey']")

# Set the ruby path so that rumm and ruby can be accessed
# change ruby versions here
# export PATH=${PATH}:${HOME}/.rbenv/bin:${HOME}/.rbenv/shims:${HOME}/.rbenv/versions/1.9.3-p448/bin
export PATH=${PATH}:/opt/chef/embedded/bin

#
# Setup environment variables and rax credential files for ansible
#
cat <<EOF > .rax_creds_file
[rackspace_cloud]
username = $OS_USERNAME
api_key = $OS_KEY
EOF
export RAX_REGION=$OS_REGION_NAME_UPPER

#
# Setup rax monitoring cli .raxrc file
#
cat <<EOF > .raxrc
[credentials]
username=${OS_USERNAME}
api_key=${OS_KEY}

[api]
url=https://monitoring.api.rackspacecloud.com/v1.0

[auth_api]
url=${OS_AUTH_URL}/tokens

[ssl]
verify=true
EOF

#
# Setup swiftly configuration
#
cat <<EOF > .swiftly.conf
[swiftly]
auth_url =  ${OS_AUTH_URL}
#   The URL to the auth system, example:
#   https://identity.api.rackspacecloud.com/v2.0
auth_user = ${OS_USERNAME}
#   The user name for the auth system, example: test:tester
auth_key = ${OS_KEY}
#   The key for the auth system, example: testing
auth_tenant = ${HEAT_TENANT_ID}
#   The tenant name for the auth system, example: test
#   If not specified and needed, the auth user will be used.
# auth_methods = <name>[,<name>[...]]
#   Auth methods to use with the auth system, example:
#   auth2key,auth2password,auth2password_force_tenant,auth1
#   The best order will try to be determined for you; but if you notice it
#   keeps making useless auth attempts and that drives you crazy, you can
#   override that here. All the available auth methods are listed in the
#   example.
region = ${OS_REGION_NAME_UPPER}
#   Region to use, if supported by auth, example: DFW
#   Default: default region specified by the auth response.
# direct = <path>
#   Uses direct connect method to access Swift. Requires access to rings and
#   backend servers. The PATH is the account path, example: /v1/AUTH_test
# proxy = <url>
#   Uses the given HTTP proxy URL.
# snet = <boolean>
#   If set true, prepends the storage URL host name with "snet-". Mostly only
#   useful with Rackspace Cloud Files and Rackspace ServiceNet.
# retries = <integer>
#   Indicates how many times to retry the request on a server error. Default: 4
cache_auth = true
#   If set true, the storage URL and auth token are cached in your OS temporary
#   directory as <user>.swiftly for reuse. If there are already cached values,
#   they are used without authenticating first.
# cdn = <boolean>
#   If set true, directs requests to the CDN management interface.
# concurrency = <integer>
#   Sets the the number of actions that can be done simultaneously when
#   possible (currently requires using Eventlet too). Default: 1
#   Note that some nested actions may amplify the number of concurrent actions.
#   For instance, a put of an entire directory will use up to this number of
#   concurrent actions. A put of a segmented object will use up to this number
#   of concurrent actions. But, if a directory structure put is uploading
#   segmented objects, this nesting could cause up to <integer> * <integer>
#   concurrent actions.
eventlet = true
#   If set true, enables Eventlet, if installed. This is disabled by default if
#   Eventlet is not installed or is less than version 0.11.0 (because older
#   Swiftly+Eventlet tends to use excessive CPU.
# verbose = <boolean>
#   Causes output to standard error indicating actions being taken. These
#   output lines will be prefixed with VERBOSE and will also include the number
#   of seconds elapsed since the command started.
EOF

#
# Setup ansible environment variables
#
export RAX_CREDS_FILE=~/.rax_creds_file
export ANSIBLE_HOST_KEY_CHECKING=False

#
# set LC_ALL to a more common character set
export LC_ALL=en_US.UTF-8

#
# Configure the lava client
#
export AUTH_TOKEN=$CLOUD_SERVERS_API_TOKEN
# export LAVA_API_URL=https://dfw.bigdata.api.rackspacecloud.com/v1.0/12345
export LAVA_API_URL=$(keystone catalog --service rax:bigdata 2> /dev/null | grep publicURL | grep $OS_REGION_NAME_LOWER | cut -d ' ' -f4)
if [ -z $LAVA_API_URL ];then
  echo "WARNING: The lava client won't work for the region $OS_REGION_NAME, rax:bigdata service wasn't found"
fi

#
# Setup openstack commandline overides for certain command line. Source functions from openstack_cli_functions
#
source ./.openstack_cli_functions.sh
