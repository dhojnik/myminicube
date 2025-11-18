#!/bin/bash
set -e

# ---------------------------------------------
# Detect kubectl or fallback to minikube kubectl
# ---------------------------------------------
if command -v kubectl >/dev/null 2>&1; then
    KUBECTL="kubectl"
else
    KUBECTL="minikube kubectl --"
fi

echo "Using Kubernetes command: $KUBECTL"
echo

# ---------------------------------------------
# YAML files list
# ---------------------------------------------
YAML_FILES=(
    traefik-namespace.yml
    traefik-configmap.yml
    traefik-crds.yml
    traefik-pvc.yml
    traefik-deployment.yml
    traefik-service.yml
    webapp-deployment.yml
    webapp-service.yml
    webapp-ingressroute.yml
)

# ---------------------------------------------
# Deploy all resources
# ---------------------------------------------
deploy() {
    for file in "${YAML_FILES[@]}"; do
        echo "Applying $file ..."
        $KUBECTL apply -f "$file"
    done
    echo
    echo "Deployment finished."
}

# ---------------------------------------------
# Delete all resources
# ---------------------------------------------
delete_all() {
    for file in "${YAML_FILES[@]}"; do
        echo "Deleting $file ..."
        $KUBECTL delete -f "$file" --ignore-not-found
    done
    echo
    echo "Delete finished."
}

# ---------------------------------------------
# Status
# ---------------------------------------------
status() {
    $KUBECTL get pods -A
}

# ---------------------------------------------
# Help menu
# ---------------------------------------------
help_menu() {
    echo "Usage: ./deploy.sh [deploy|delete|redeploy|status]"
    exit 0
}

# ---------------------------------------------
# Main
# ---------------------------------------------
case "$1" in
    deploy)
        deploy
        ;;
    delete)
        delete_all
        ;;
    redeploy)
        delete_all
        deploy
        ;;
    status)
        status
        ;;
    *)
        help_menu
        ;;
esac

