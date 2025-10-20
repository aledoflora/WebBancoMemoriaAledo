#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import json
from pathlib import Path

RECETARIO_DIR = Path(__file__).resolve().parent.parent / 'data' / 'recetario'

def is_image(name):
    return name.lower().endswith(('.jpg','.jpeg','.png','.gif','.bmp','.webp'))

def is_pdf(name):
    return name.lower().endswith('.pdf')

def generate_indexes():
    if not RECETARIO_DIR.exists():
        print('Error: no existe', RECETARIO_DIR)
        return

    for entry in sorted(RECETARIO_DIR.iterdir()):
        if not entry.is_dir():
            continue
        folder = entry
        try:
            files = sorted([f.name for f in folder.iterdir() if f.is_file()])
        except Exception as e:
            print('No se pudo leer', folder, e)
            continue

        images = [f for f in files if is_image(f)]
        pdfs = [f for f in files if is_pdf(f)]

        index = {
            'folder': folder.name,
            'files': files,
            'cover': images[0] if images else None,
            'pdf': pdfs[0] if pdfs else None,
            'generatedAt': __import__('datetime').datetime.utcnow().isoformat() + 'Z'
        }

        out = folder / 'index.json'
        try:
            with open(out, 'w', encoding='utf-8') as fh:
                json.dump(index, fh, ensure_ascii=False, indent=2)
            print('Wrote', out, 'cover=', index['cover'], 'pdf=', index['pdf'])
        except Exception as e:
            print('Error escribiendo', out, e)

if __name__ == '__main__':
    generate_indexes()
