#!/bin/sh
TESTNAME="sno-lso"
cd ../

# Delete existing environments
R_CLUSTER_IDS=$(ANSIBLE_STDOUT_CALLBACK=json ansible-playbook get_cluster_id_by_name.yaml -e cluster_name=${TESTNAME} 2>/dev/null \
|  jq -r '.plays[0].tasks[-1].hosts.localhost.filter_ids')
echo $R_CLUSTER_IDS
if [ "${R_CLUSTER_IDS}" != "VARIABLE IS NOT DEFINED!" ]; then
  CLUSTER_IDS=$(echo $R_CLUSTER_IDS | jq -r '.[]')
  for cluster_id in ${CLUSTER_IDS}; do
    ansible-playbook sno_lso_kubevirt.yaml -e action='delete' -e cluster_id=${cluster_id} -e cluster_name=${TESTNAME} -e ocp_namespace=test-${TESTNAME}
  done
fi
if oc get project test-${TESTNAME}; then
  oc delete project test-${TESTNAME} --wait=true
fi
# Create new environment

oc new-project test-${TESTNAME} 
ansible-playbook sno_lso_kubevirt.yaml -e cluster_name=${TESTNAME} -e ocp_namespace=test-${TESTNAME} -e overwrite_dns=true

