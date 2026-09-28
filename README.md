# Build y Push de Imágenes - EOL Lilac Staging

Construcción de imagen Docker **EOL Lilac Staging** y almacenamiento en `ghcr.io/eol-uchile/openedx-eol`.

## Estructura
- `.env`: versiones, repositorios, imagen destino y caché 
- `env/build/openedx/requirements/`: requirements de la plataforma; `private.txt` incluye el resto con `-r` 
- `env/build/openedx/themes/`: temas (submódulos git) 

El resto de `env/` lo genera Tutor y está ignorado en git.

## Pipeline (GitHub Actions)

Todo el workflow vive en `.github/workflows/build.yml`. Al hacer push o PR a `eol/*` o `eol-release/*`:

1. Hace checkout del código incluyendo los submódulos de temas
2. Carga las variables requeridas desde `.env`
3. Configura Tutor (`EDX_PLATFORM_*`, `OPENEDX_COMMON_VERSION`, `DOCKER_IMAGE_OPENEDX`)
4. Descarga los locales desde el fork de la plataforma
5. Construye la imagen usando caché remoto (`cache-from`/`cache-to`)
6. Etiqueta la imagen (`<prefix>`, `<prefix>-<sha>`, `<prefix>-<timestamp>`) y la publica en GHCR

## Ejecución local con act

[act](https://github.com/nektos/act) permite ejecutar el workflow localmente para desarrollo y depuración sin necesidad de subir commits o depender de GitHub Actions.

### Prerrequisitos
Asegurarse de inicializar los submódulos de git antes de ejecutar `act`:
```bash
git submodule update --init --recursive
```

### Ejecución básica
Para ejecutar el workflow simulando un evento de `push`:
```bash
act push -W .github/workflows/build.yml --bind
```

- `-W .github/workflows/build.yml`: especifica el archivo de workflow a disparar
- `--bind`: monta el directorio actual dentro del contenedor, permitiendo a Tutor y Docker acceder a los insumos y reflejar cambios en el working tree

### Comportamiento en entorno local
Los pasos de **Login a GitHub Container Registry** y **Push OPENEDX images** se omiten automáticamente gracias a la condición `if: ${{ env.ACT != 'true' }}`, esto evita requerir credenciales de GitHub o publicar imágenes.

### Simulación de Pull Request
Para probar el workflow simulando un evento de Pull Request desde una rama de trabajo, se necesita crear un archivo `pull_request.json` en la raíz del proyecto con la siguiente estructura:
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
*Reemplaza `head.ref` con la rama de trabajo y `base.ref` con la rama destino del PR*

Luego ejecutar:
```bash
act pull_request -W .github/workflows/build.yml --bind --eventpath pull_request.json
```
