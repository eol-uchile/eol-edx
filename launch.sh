#!/bin/bash
set -e

# Activar entorno virtual si existe
if [ -f ".venv/bin/activate" ]; then
  source .venv/bin/activate
fi

export TUTOR_ROOT=$(pwd)

source ./build.sh

# Deshabilitar plugins que no son para local
tutor plugins disable gitops || true

tutor config save --set LMS_HOST="localhost:8000"
tutor config save --set CMS_HOST="localhost:8001"
tutor config save --set ENABLE_WEB_PROXY=true
tutor config save --set ENABLE_HTTPS=false
tutor config save --set RUN_SMTP=false
tutor config save --set PLATFORM_NAME='Plataforma EOL (Local)'

tutor config save
# tutor local launch
