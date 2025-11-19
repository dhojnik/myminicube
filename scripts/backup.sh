#!/bin/bash
set -e
NAMESPACE="webapp"
OUT="backup-$(date +%F-%H-%M)"
mkdir -p "$OUT"

kubectl get deploy -n $NAMESPACE -o yaml > "$OUT/deployment.yaml"
kubectl get svc -n $NAMESPACE -o yaml > "$OUT/service.yaml"
kubectl get ingress -n $NAMESPACE -o yaml > "$OUT/ingress.yaml"
kubectl get ingressclass -o yaml > "$OUT/ingressclass.yaml"

echo "Backup complete: $OUT/"
