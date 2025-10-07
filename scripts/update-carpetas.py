#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
import sys
from pathlib import Path
from datetime import datetime

def update_carpetas_json():
    """Actualiza automáticamente el archivo JSON de carpetas del recetario"""
    
    # Ruta al directorio del recetario
    script_dir = Path(__file__).parent
    recetario_path = script_dir.parent / 'data' / 'recetario'
    
    try:
        # Leer el contenido del directorio
        carpetas = []
        for item in recetario_path.iterdir():
            if item.is_dir():
                carpetas.append(item.name)
        
        # Ordenar alfabéticamente
        carpetas.sort()
        
        # Crear el objeto JSON
        json_data = {
            "carpetas": carpetas,
            "notas": "Este archivo se actualiza automáticamente. No editar manualmente.",
            "ultimaActualizacion": datetime.now().isoformat()
        }
        
        # Escribir el archivo JSON
        json_path = recetario_path / 'carpetas.json'
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2, ensure_ascii=False)
        
        print('✅ JSON actualizado exitosamente')
        print(f'📁 Carpetas detectadas: {len(carpetas)}')
        print(f'📝 Carpetas: {", ".join(carpetas)}')
        
    except Exception as error:
        print(f'❌ Error al actualizar el JSON: {error}')

if __name__ == '__main__':
    update_carpetas_json()
    
    # Si se ejecuta con --watch, observar cambios (requiere watchdog)
    if '--watch' in sys.argv:
        try:
            from watchdog.observers import Observer
            from watchdog.events import FileSystemEventHandler
            
            class CarpetaHandler(FileSystemEventHandler):
                def on_any_event(self, event):
                    if not event.is_directory and not event.src_path.endswith('.json'):
                        print(f'🔄 Cambio detectado: {os.path.basename(event.src_path)}')
                        update_carpetas_json()
            
            print('👀 Observando cambios en el directorio...')
            event_handler = CarpetaHandler()
            observer = Observer()
            observer.schedule(event_handler, str(recetario_path), recursive=True)
            observer.start()
            
            try:
                while True:
                    pass
            except KeyboardInterrupt:
                observer.stop()
            observer.join()
            
        except ImportError:
            print('⚠️ Para usar --watch, instala watchdog: pip install watchdog')
