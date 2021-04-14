####################################
# Coolstore Application Deployment #
####################################

DIRECTORY=`dirname $0`

for project in package-deploy-dev package-deploy-staging package-deploy
do
  oc new-project ${project}
  oc apply -f ${DIRECTORY}/solutions/tasks -n ${project}
  oc create configmap argocd-env-configmap \
    --from-literal=ARGOCD_SERVER=argocd-cluster-server.openshift-gitops.svc \
    -n ${project}

  oc create secret generic argocd-env-secret \
    --from-literal=ARGOCD_USERNAME=admin \
    --from-literal=ARGOCD_PASSWORD=$(oc get secret argocd-cluster-cluster -n openshift-gitops -o yaml |grep "  admin.password" | awk '{print $2}' | base64 -D) \
    -n ${project} 
done

oc apply -f ${DIRECTORY}/solutions/openshift
oc apply -f ${DIRECTORY}/solutions/helm
oc apply -f ${DIRECTORY}/solutions/argoCD
