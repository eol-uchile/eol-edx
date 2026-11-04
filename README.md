# Build y Push de Imágenes - EOL Lilac Staging

Construcción de imagen Docker **EOL Lilac Staging** y almacenamiento en `ghcr.io/eol-uchile/openedx-eol`.

## Estructura
- `.env`: versiones, repositorios, imagen destino y caché 
- `env/build/openedx/requirements/`: requirements de la plataforma; `private.txt` incluye el resto con `-r` 
- `env/build/openedx/themes/`: temas (submódulos git) 
- `Dockerfile`: etapa multi-stage basada en `rclone/rclone` para extraer `/openedx/staticfiles` hacia `/data` y servir/sincronizar assets con S3

El resto de `env/` lo genera Tutor y está ignorado en git.

## Pipeline (GitHub Actions)

Todo el workflow vive en `.github/workflows/build.yml`. Al hacer push o PR a `eol/*` o `eol-release/*`:

1. Hace checkout del código incluyendo los submódulos de temas
2. Carga las variables requeridas desde `.env`
3. Configura Tutor (`EDX_PLATFORM_*`, `OPENEDX_COMMON_VERSION`, `DOCKER_IMAGE_OPENEDX`)
4. Descarga los locales desde el fork de la plataforma
5. Construye la imagen de Open edX usando caché remoto (`cache-from`/`cache-to`)
6. Etiqueta la imagen principal (`<prefix>`, `<prefix>-<sha>`, `<prefix>-<timestamp>`)
7. Construye y etiqueta la imagen de cliente S3 con los assets de Open edX (`assets-<prefix>`, `assets-<prefix>-<sha>`, `assets-<prefix>-<timestamp>`) basada en `rclone/rclone`
8. Publica ambas imágenes con todos sus tags en GHCR

## Ejecución local con act

[act](https://github.com/nektos/act) permite ejecutar el workflow localmente para desarrollo y depuración. Para más detalles sobre la configuración de `act`, consultar la [documentación en workflow-commons](https://github.com/eol-uchile/workflow-commons#local-run-with-act).

### Prerrequisitos
Asegurarse de inicializar los submódulos de git antes de ejecutar `act`:
```bash
git submodule update --init --recursive
```

### Ejecución
Para probar el workflow localmente simulando Pull Request:

1. Crear un archivo `pull_request.json` en la raíz del proyecto:
```json
{
  "pull_request": {
    "head": {
      "ref": "vastorga/add-lilac"
    },
    "base": {
      "ref": "eol/lilac"
    }
  }
}
```
*Reemplaza `head.ref` con la rama de trabajo y `base.ref` con la rama destino.*

2. Ejecutar `act`:
```bash
act pull_request -W .github/workflows/build.yml --bind --eventpath pull_request.json
```
