# Scripts de Automatización para el Recetario

Este directorio contiene scripts para automatizar la actualización del archivo `carpetas.json` del recetario, eliminando la necesidad de editar manualmente la lista de carpetas.

## Opciones Disponibles

### 1. Script Node.js (Recomendado)
**Archivo:** `update-carpetas.js`

**Uso básico:**
```bash
node update-carpetas.js
```

**Uso con observación automática:**
```bash
node update-carpetas.js --watch
```

**Requisitos:** Node.js instalado

### 2. Script Python
**Archivo:** `update-carpetas.py`

**Uso básico:**
```bash
python update-carpetas.py
```

**Uso con observación automática:**
```bash
python update-carpetas.py --watch
```

**Requisitos:** Python 3.x (para --watch: `pip install watchdog`)

### 3. Script PowerShell (Windows)
**Archivo:** `update-carpetas.ps1`

**Uso básico:**
```powershell
.\update-carpetas.ps1
```

**Uso con observación automática:**
```powershell
.\update-carpetas.ps1 -Watch
```

**Requisitos:** PowerShell (Windows)

## ¿Qué hace cada script?

1. **Escanea** el directorio `data/recetario/`
2. **Detecta** todas las carpetas (excluyendo archivos)
3. **Genera** automáticamente el archivo `carpetas.json` con:
   - Lista de carpetas encontradas
   - Nota de que es auto-generado
   - Timestamp de última actualización

## Modo de Observación

Los scripts pueden ejecutarse en modo "watch" que:
- Observa cambios en el directorio del recetario
- Actualiza automáticamente el JSON cuando se añaden/eliminan carpetas
- Se ejecuta continuamente hasta que se interrumpe (Ctrl+C)

## Alternativa: Sin JSON

El archivo `recetario.html` ya está configurado para funcionar **sin necesidad del JSON**:
- Si el JSON existe, lo usa
- Si no existe, detecta automáticamente las carpetas
- La detección automática busca carpetas con nombres como `prueba1`, `prueba2`, etc.

## Recomendación

Para máxima simplicidad, puedes:
1. **Eliminar** el archivo `carpetas.json` 
2. **Usar solo** la detección automática del HTML
3. **Asegurarte** de que las carpetas tengan nombres predecibles (ej: `receta1`, `receta2`, etc.)

## Estructura de Carpetas Esperada

```
data/recetario/
├── carpeta1/
│   ├── cr7.jpg (imagen de portada)
│   └── PRUEBA.pdf (documento de la receta)
├── carpeta2/
│   ├── cr7.jpg
│   └── PRUEBA.pdf
└── carpetas.json (auto-generado)
```
