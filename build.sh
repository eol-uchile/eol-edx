#!/bin/bash
set -e

if [ -z "$EDX_PLATFORM_VERSION" ] || [ -z "$OPENEDX_COMMON_VERSION" ] || [ -z "$EDX_PLATFORM_REPOSITORY" ]; then
    echo "ERROR: variables EDX_PLATFORM_VERSION, OPENEDX_COMMON_VERSION y/o EDX_PLATFORM_REPOSITORY no definidas."
    exit 1
fi

# Activar entorno virtual si existe
if [ -f ".venv/bin/activate" ]; then
  source .venv/bin/activate
fi

export TUTOR_ROOT=$(pwd)

# Indicar el repositorio base del fork de EOL y su version
tutor config save --set EDX_PLATFORM_REPOSITORY="${EDX_PLATFORM_REPOSITORY}"
tutor config save --set EDX_PLATFORM_VERSION="${EDX_PLATFORM_VERSION}"
tutor config save --set OPENEDX_COMMON_VERSION="${OPENEDX_COMMON_VERSION}"

mkdir -p env/build/openedx/locale/eol

# We remove any previous clone in case we run this locally multiple times
rm -rf env/build/openedx/locale/eol/.git
git clone --no-checkout --depth=1 --filter=tree:0 --branch "${EDX_PLATFORM_VERSION}" https://github.com/eol-uchile/edx-platform/ env/build/openedx/locale/eol
git -C env/build/openedx/locale/eol sparse-checkout set --no-cone /conf/locale/
git -C env/build/openedx/locale/eol checkout

# Asegurar que submodulos de temas estén clonados
git submodule update --init --depth=1 themes/ 2>/dev/null || true
mkdir -p env/build/openedx/themes/
cp -r themes/* env/build/openedx/themes/ 2>/dev/null || true

# Concatenar requirements locales para que se instalen en la imagen
mkdir -p env/build/openedx/requirements/
cat requirements/*.txt > env/build/openedx/requirements/private.txt 2>/dev/null || touch env/build/openedx/requirements/private.txt
