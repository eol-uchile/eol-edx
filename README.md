# Tutor Lilac (EOL)

Despliegue GitOps para Open edX Tutor (Lilac)

## Requisitos Previos

- Python 3.8+ (tutor lilac)
- `kubectl` y `kubeseal` instalados y apuntando al cluster

## Instrucciones de Despliegue`

### 1. Preparar el Entorno Virtual
Primero debemos crear el entorno virtual e instalar las dependencias.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Configurar Secretos
Copiar la plantilla de secretos y rellenarla con las contraseñas e ID reales:

```bash
cp secrets.sh.template secrets.sh
# Editar secrets.sh y reemplazar los valores de "change-me"
vim secrets.sh
```

### 3. Generar Manifiestos de Kubernetes
Ejecutar el script de aprovisionamiento para que el plugin de GitOps y Tutor generen los archivos `.yaml` estructurales (sin incluir secretos sellados aún).

```bash
source secrets.sh
./provision.sh
```
Esto creará dos carpetas principales:
- `env/`: Contiene los archivos estáticos y configuraciones base generadas por Tutor (de aquí sacaremos la info para encriptar en el próximo paso).
- `eol-lilac-staging/` (o el nombre definido en GITOPS_OUTPUT_DIR): Contiene los manifiestos de Kubernetes de GitOps listos para desplegar.

### 4. Sellar los Secretos contra el Cluster
Asegúrate de estar apuntando al cluster correcto (ej. `sandbox`) para que `kubeseal` encripte usando la llave pública de ese cluster.

```bash
kubectl config use-context sandbox
source secrets.sh
./seal_secrets.sh
```
Esto generará los archivos `sealed-*.yaml` en la carpeta `env-custom/` (o la ruta configurada en el script) y los dejará listos para integrarse al despliegue.

### 5. Desplegar
Sube los archivos generados (tanto la salida de `provision.sh` como los secretos de `seal_secrets.sh`) al repositorio que lee ArgoCD y sincroniza la aplicación en el cluster.
