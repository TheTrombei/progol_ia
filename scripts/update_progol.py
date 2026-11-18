#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de automatización para Progol IA.
Obtiene la cartelera actual de Progol (14 partidos) y Progol Media Semana (9 partidos)
y genera los pronósticos (L, E, V) utilizando la API de Google Gemini (gemini-2.5-flash)
con búsqueda web (Google Search Grounding) activada.
"""

import os
import sys
import json
import re
from datetime import datetime, timezone
import urllib.request
import urllib.error

# Modelos con fallback automático en caso de rotación o deprecación
MODELS_TO_TRY = [
    "gemini-flash-lite-latest",
    "gemini-3.8-flash",
    "gemini-flash-latest",
    "gemini-2.5-flash",
]
API_URL_TEMPLATE = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}"

PROMPT_TEXT = """
Eres un analista deportivo profesional especializado en el fútbol mexicano e internacional y en las quinielas oficiales de Pronósticos para la Asistencia Pública / Lotería Nacional de México ("Progol" y "Progol Media Semana").

UTILIZA TU HERRAMIENTA DE BÚSQUEDA (Google Search) para encontrar la cartelera oficial y activa más reciente de la semana:
1. Quiniela "Progol" de Fin de Semana (Concurso actual, exactamente 14 partidos oficiales).
2. Quiniela "Progol Media Semana" (Concurso actual, exactamente 9 partidos oficiales).

Para cada partido de ambas quinielas:
1. Extrae el número oficial de partido (del 1 al 14 para Progol, y del 1 al 9 para Media Semana).
2. Extrae el nombre del Equipo Local y Equipo Visita exactos.
3. Analiza la forma reciente de ambos equipos, su posición en la tabla, desempeño como local/visitante, bajas y enfrentamientos directos.
4. Determina la predicción más probable del resultado del partido usando EXCLUSIVAMENTE una de las tres letras:
   - "L" para victoria del Equipo Local.
   - "E" para Empate.
   - "V" para victoria del Equipo Visita.

IMPORTANTE:
Debes responder ÚNICAMENTE con un objeto JSON válido, sin texto antes ni después, con la siguiente estructura exacta:
{
  "progol": {
    "quiniela": "Progol",
    "concurso": "2258",
    "semana": "Semana actual / Fecha",
    "partidos": [
      {
        "numero": 1,
        "local": "Nombre Equipo Local",
        "visita": "Nombre Equipo Visita",
        "prediccion": "L"
      }
    ]
  },
  "media_semana": {
    "quiniela": "Progol Media Semana",
    "concurso": "712",
    "semana": "Media Semana actual / Fecha",
    "partidos": [
      {
        "numero": 1,
        "local": "Nombre Equipo Local",
        "visita": "Nombre Equipo Visita",
        "prediccion": "E"
      }
    ]
  }
}
"""

def extract_json_from_text(text: str) -> dict:
    """Extrae y decodifica un bloque JSON desde la respuesta del modelo."""
    text = text.strip()
    
    # Intentar búsqueda con delimitadores markdown ```json ... ```
    json_match = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text, re.IGNORECASE)
    if json_match:
        text = json_match.group(1).strip()
    else:
        # Si no tiene backticks, buscar las llaves externas { ... }
        start = text.find("{")
        end = text.rfind("}")
        if start != -1 and end != -1:
            text = text[start:end+1]
            
    return json.loads(text)

def validate_and_normalize_data(data: dict) -> dict:
    """Valida y asegura que las quinielas cumplan con el formato esperado."""
    now_iso = datetime.now(timezone.utc).isoformat()
    result = {
        "actualizado_en": now_iso,
        "progol": {
            "quiniela": "Progol",
            "concurso": "Actual",
            "semana": "Fin de Semana",
            "partidos": []
        },
        "media_semana": {
            "quiniela": "Progol Media Semana",
            "concurso": "Actual",
            "semana": "Media Semana",
            "partidos": []
        }
    }

    for key in ["progol", "media_semana"]:
        section = data.get(key, {})
        if not section:
            continue
            
        result[key]["quiniela"] = section.get("quiniela", "Progol" if key == "progol" else "Progol Media Semana")
        result[key]["concurso"] = str(section.get("concurso", "Actual"))
        result[key]["semana"] = str(section.get("semana", "Semana Oficial"))
        
        partidos_raw = section.get("partidos", [])
        partidos_cleaned = []
        
        for idx, item in enumerate(partidos_raw, start=1):
            num = item.get("numero", idx)
            local = str(item.get("local", "Local")).strip()
            visita = str(item.get("visita", "Visita")).strip()
            pred = str(item.get("prediccion", "L")).strip().upper()
            
            # Normalizar predicción a L, E o V
            if pred not in ["L", "E", "V"]:
                if "EMPATE" in pred or "DRAW" in pred or "X" in pred:
                    pred = "E"
                elif "VISITA" in pred or "AWAY" in pred or "V" in pred:
                    pred = "V"
                else:
                    pred = "L"
                    
            partidos_cleaned.append({
                "numero": int(num),
                "local": local,
                "visita": visita,
                "prediccion": pred
            })
            
        result[key]["partidos"] = partidos_cleaned

    return result

def query_gemini_api(api_key: str) -> dict:
    """Consulta la API de Gemini con Google Search Grounding activado, probando modelos disponibles."""
    last_err = None

    for model in MODELS_TO_TRY:
        url = API_URL_TEMPLATE.format(model=model, key=api_key)
        
        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": PROMPT_TEXT}
                    ]
                }
            ],
            "tools": [
                {
                    "google_search": {}
                }
            ],
            "generationConfig": {
                "temperature": 0.2
            }
        }
        
        headers = {
            "Content-Type": "application/json"
        }
        
        data_bytes = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=data_bytes, headers=headers, method="POST")
        
        print(f"[*] Intentando con modelo: {model} (Google Search Grounding activado)...")
        try:
            with urllib.request.urlopen(req, timeout=60) as response:
                resp_body = response.read().decode("utf-8")
                resp_json = json.loads(resp_body)
                
            candidates = resp_json.get("candidates", [])
            if candidates:
                parts = candidates[0].get("content", {}).get("parts", [])
                combined_text = "".join(part.get("text", "") for part in parts if "text" in part)
                if combined_text:
                    print(f"[+] Respuesta recibida exitosamente de {model}.")
                    return extract_json_from_text(combined_text)
        except urllib.error.HTTPError as e:
            err_msg = e.read().decode('utf-8', errors='ignore')
            print(f"[!] Error HTTP {e.code} con {model}: {err_msg[:200]}")
            last_err = e
        except Exception as e:
            print(f"[!] Error con {model}: {e}")
            last_err = e

    if last_err:
        raise last_err
    raise ValueError("No se pudo obtener respuesta válida de ningún modelo de Gemini.")

def main():
    print("=" * 60)
    print("        PROGOL IA - ACTUALIZADOR DE QUINIELAS")
    print("=" * 60)
    
    api_key = os.environ.get("GEMINI_API_KEY", "").strip()
    output_path = os.path.join(os.getcwd(), "progol_data.json")
    asset_path = os.path.join(os.getcwd(), "assets", "progol_data.json")

    data = None
    if not api_key:
        print("[!] AVISO: Variable GEMINI_API_KEY no configurada.")
        if os.path.exists(output_path):
            print("[+] Leyendo archivo progol_data.json existente para validar y actualizar timestamp.")
            with open(output_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            data["actualizado_en"] = datetime.now(timezone.utc).isoformat()
        else:
            print("[+] Generando datos base por defecto...")
            data = None
    else:
        try:
            raw_data = query_gemini_api(api_key)
            data = validate_and_normalize_data(raw_data)
            print("[+] Predicciones obtenidas con éxito de Gemini.")
        except Exception as e:
            print(f"[!] Error al comunicarse con Gemini: {e}")
            if os.path.exists(output_path):
                print("[*] Manteniendo el archivo existente con actualización de timestamp.")
                with open(output_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                data["actualizado_en"] = datetime.now(timezone.utc).isoformat()

    if data:
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"[+] Archivo guardado correctamente en: {output_path}")

        # Guardar también copia en assets si existe el directorio
        if os.path.exists(os.path.dirname(asset_path)):
            with open(asset_path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"[+] Copia actualizada en assets: {asset_path}")

        # Resumen de partidos procesados
        p_count = len(data.get("progol", {}).get("partidos", []))
        ms_count = len(data.get("media_semana", {}).get("partidos", []))
        print(f"[*] Resumen: Progol ({p_count} partidos) | Media Semana ({ms_count} partidos)")
    else:
        print("[!] No se generaron datos nuevos ni existen previos.")
        sys.exit(1)

    print("[+] Proceso completado exitosamente.")

if __name__ == "__main__":
    main()
