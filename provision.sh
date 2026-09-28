#!/bin/bash
set -e

export TUTOR_ROOT=$(pwd)

source ./build.sh

# Validate secrets and ID
if [ -z "$DEPLOY_NAMESPACE" ] || [ -z "$GITOPS_OUTPUT_DIR" ] || [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$OPENEDX_MYSQL_PASSWORD" ] || [ -z "$MINIO_ROOT_PASSWORD" ]; then
    echo "ERROR: Faltan variables de entorno requeridas. Por favor ejecuta primero: source secrets.sh"
    exit 1
fi

# Disable conflicting plugins
tutor plugins disable mfe || true

# Configuración base
tutor config save --set PLATFORM_NAME='Plataforma EOL (Lilac)'
tutor config save --set CONTACT_EMAIL=eol-ing@uchile.cl
tutor config save --set LANGUAGE_CODE=es-es

# Configuración de dominios
tutor config save --set LMS_HOST="lms.areteia.site"
tutor config save --set CMS_HOST="cms.areteia.site"
tutor config save --set PREVIEW_LMS_HOST="preview.areteia.site"
tutor config save --set MFE_HOST="apps.areteia.site"
tutor config save --set MINIO_HOST="minio.areteia.site"

# Ingress/Gateway API
tutor config save --set ENABLE_WEB_PROXY=false
tutor config save --set ENABLE_HTTPS=true
tutor config save --set RUN_SMTP=false

# Configuración de namespace
tutor config save --set K8S_NAMESPACE="eol-lilac-staging"

# ID de la instancia
tutor config save --set ID="${TUTOR_ID}"

# Imagen EOL
tutor config save --set DOCKER_IMAGE_OPENEDX=ghcr.io/eol-uchile/openedx-eol:lilac-staging

# Habilitar plugins necesarios
tutor plugins enable minio
tutor config save --set MINIO_DOCKER_IMAGE=ghcr.io/eol-uchile/minio:release.2024-10-13t13-34-11z
tutor config save --set MINIO_MC_DOCKER_IMAGE=ghcr.io/eol-uchile/mc:release.2024-10-29t15-34-59z

# Setea claves en los archivos de configuración estáticos del LMS/CMS
tutor config save --set OPENEDX_MYSQL_PASSWORD="${OPENEDX_MYSQL_PASSWORD}"
tutor config save --set OPENEDX_SECRET_KEY="${OPENEDX_SECRET_KEY}"
tutor config save --set OPENEDX_AWS_ACCESS_KEY="${MINIO_ROOT_USER}"
tutor config save --set OPENEDX_AWS_SECRET_ACCESS_KEY="${MINIO_ROOT_PASSWORD}"

# Gitops
# Ensure gitops plugin is installed
pip install git+https://github.com/eol-uchile/tutor-gitops-plugin.git@main
tutor plugins enable gitops

# Generate manifests
tutor config save
