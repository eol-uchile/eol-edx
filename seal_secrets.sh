#!/bin/bash
set -e

# Asegurar que se cargaron las variables del secrets.sh
if [ -z "$DEPLOY_NAMESPACE" ] || [ -z "$OPENEDX_SECRET_KEY" ] || [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$OPENEDX_MYSQL_PASSWORD" ] || [ -z "$MINIO_ROOT_PASSWORD" ]; then
    echo "ERROR: Faltan variables de entorno."
    echo "Por favor ejecuta primero: source secrets.sh"
    exit 1
fi

MINIO_ROOT_USER=${MINIO_ROOT_USER:-openedx}

# Controller config
CONTROLLER_NS="sealed-secrets"
CONTROLLER_NAME="sealed-secrets-controller"

# Output dir
OUT_DIR="${GITOPS_OUTPUT_DIR}/secrets"
mkdir -p "$OUT_DIR"

# 1. deployment-secrets (Adaptado para Lilac)
kubectl create secret generic deployment-secrets \
  --from-literal=MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" \
  --from-literal=OPENEDX_MYSQL_PASSWORD="${OPENEDX_MYSQL_PASSWORD}" \
  --from-literal=DISCOVERY_MYSQL_PASSWORD="${DISCOVERY_MYSQL_PASSWORD}" \
  --from-literal=MINIO_ROOT_USER="${MINIO_ROOT_USER}" \
  --from-literal=MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD}" \
  --namespace=$DEPLOY_NAMESPACE --dry-run=client -o yaml \
  | kubeseal --controller-namespace $CONTROLLER_NS --controller-name $CONTROLLER_NAME -o yaml > $OUT_DIR/sealed-deployments.yaml
echo "Sealed deployment-secrets"

# 2. openedx-config
kubectl create secret generic openedx-config \
  --from-file=env/apps/openedx/config/ \
  --namespace=$DEPLOY_NAMESPACE --dry-run=client -o yaml \
  | kubeseal --controller-namespace $CONTROLLER_NS --controller-name $CONTROLLER_NAME -o yaml > $OUT_DIR/sealed-config.yaml
echo "Sealed openedx-config"

# 3. openedx-settings-lms
kubectl create secret generic openedx-settings-lms \
  --from-file=env/apps/openedx/settings/lms/production.py \
  --from-file=env/apps/openedx/settings/lms/__init__.py \
  --namespace=$DEPLOY_NAMESPACE --dry-run=client -o yaml \
  | kubeseal --controller-namespace $CONTROLLER_NS --controller-name $CONTROLLER_NAME -o yaml > $OUT_DIR/sealed-settings-lms.yaml
echo "Sealed openedx-settings-lms"

# 4. openedx-settings-cms
kubectl create secret generic openedx-settings-cms \
  --from-file=env/apps/openedx/settings/cms/production.py \
  --from-file=env/apps/openedx/settings/cms/__init__.py \
  --namespace=$DEPLOY_NAMESPACE --dry-run=client -o yaml \
  | kubeseal --controller-namespace $CONTROLLER_NS --controller-name $CONTROLLER_NAME -o yaml > $OUT_DIR/sealed-settings-cms.yaml
echo "Sealed openedx-settings-cms"

# 5. discovery-settings
kubectl create secret generic discovery-settings \
  --from-file=env/plugins/discovery/apps/settings/tutor/production.py \
  --from-file=env/plugins/discovery/apps/settings/tutor/__init__.py \
  --namespace=$DEPLOY_NAMESPACE --dry-run=client -o yaml \
  | kubeseal --controller-namespace $CONTROLLER_NS --controller-name $CONTROLLER_NAME -o yaml > $OUT_DIR/sealed-settings-discovery.yaml
echo "Sealed discovery-settings"

cat <<EOF > "$OUT_DIR/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
$(ls -1 "$OUT_DIR"/*.yaml 2>/dev/null | grep -v "kustomization.yaml" | while read -r file; do echo "  - $(basename "$file")"; done)
EOF
