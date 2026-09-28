#!/bin/bash
set -e

# Activar entorno virtual si existe
if [ -f ".venv/bin/activate" ]; then
  source .venv/bin/activate
fi

export TUTOR_ROOT=$(pwd)

tutor config save --set EDX_PLATFORM_VERSION=open-release/lilac.master
tutor config save --set OPENEDX_COMMON_VERSION=open-release/lilac.3

mkdir -p env/build/openedx/locale/eol

# We remove any previous clone in case we run this locally multiple times
rm -rf env/build/openedx/locale/eol/.git
git clone --no-checkout --depth=1 --filter=tree:0 --branch eol/lilac.master https://github.com/eol-uchile/edx-platform/ env/build/openedx/locale/eol
git -C env/build/openedx/locale/eol sparse-checkout set --no-cone /conf/locale/
git -C env/build/openedx/locale/eol checkout

mkdir -p env/build/openedx/requirements/eol
rm -rf env/build/openedx/requirements/eol/.git
git clone --no-checkout --depth=1 --filter=tree:0 --branch eol-release/lilac https://github.com/eol-uchile/edx-staging/ env/build/openedx/requirements/eol/
git -C env/build/openedx/requirements/eol/ sparse-checkout set --no-cone /requirements/
git -C env/build/openedx/requirements/eol/ checkout

# crea directorio de temas y clonar el tema de EOL Staging
mkdir -p env/build/openedx/themes/eol-uchile-2020
rm -rf env/build/openedx/themes/eol-uchile-2020/.git
git clone --depth=1 --branch eol-theorical/lilac https://github.com/eol-uchile/eol-uchile-theme-2020 env/build/openedx/themes/eol-uchile-2020
