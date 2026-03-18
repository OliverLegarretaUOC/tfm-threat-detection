# TFM — Video Threat Detection Pipeline

Máster en Inteligencia Artificial · Universidad [tu universidad]

Autor: Oliver Legarreta · Tutor: [nombre del tutor]

---

## Descripción

Sistema de detección de amenazas armadas en vídeo basado en visión por computador y deep learning. El pipeline combina múltiples modelos YOLOv8 en una arquitectura por etapas capaz de detectar armas, analizar la pose corporal y evaluar la intención del sujeto.

El sistema está diseñado sobre el dataset Gun Action Recognition (GAR) y se evalúa tanto a nivel de frame como a nivel de clip.

---

## Arquitectura del pipeline (4 etapas)

```
Vídeo de entrada
      │
      ▼
[Stage 1] Segmentación de personas     — YOLOv8s-seg (COCO)
      │
      ▼
[Stage 2] Detección de arma            — YOLOv8m fine-tuned  →  Alerta Nivel 1
      │
      ▼
[Stage 3] Estimación de pose (HPE)     — YOLOv8x-pose        →  Alerta Nivel 2
      │
      ▼
[Stage 4] Análisis de intención (LLM)  — Claude API (claude-sonnet-4-20250514)
```

El sistema implementa un framework de doble nivel de alerta:
- Nivel 1: arma detectada visualmente
- Nivel 2: amenaza confirmada mediante análisis de pose y postura

---

## Estructura del repositorio

```
tfm-threat-detection/
│
├── notebooks/
│   ├── 10_evaluacion.ipynb              # Evaluación cuantitativa Modelo B
│   ├── 11_pose_exploration.ipynb        # Exploración visual HPE
│   ├── 12_pose_temporal_eval.ipynb      # Evaluación cuantitativa HPE
│   ├── 13_llm_intent_analysis.ipynb     # Integración y validación LLM
│   └── 14_demo_video.ipynb              # Generación de vídeo demo anotado
│
├── results/
│   ├── results_primera_version_modelo_deteccion.csv   # Curvas de entrenamiento Modelo A
│   └── evaluation_results_B.txt                       # Resultados evaluación Modelo B
│
└── README.md
```

---

## Resultados principales

### Stage 2 — Detección de arma

| Modelo | mAP@50 | Precision | Recall | F1 (clip) | FP |
|--------|--------|-----------|--------|-----------|-----|
| Modelo A | 0.626 | 0.626 | 0.421 | 0.720 | 100 |
| Modelo B | 0.779 | 0.779 | 0.332 | 0.795 | 48 |

Modelo B entrenado con ~3.000 imágenes negativas adicionales de COCO. Reducción de FP del 52% respecto al Modelo A.

### Stage 3 — Human Pose Estimation

La integración del módulo HPE reduce los falsos positivos en un 41.7% adicional (48 → 28), con mayor impacto en categorías de personas sujetando teléfonos (N7, N8, N9).

---

## Tecnologías

- Modelos: [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics)
- Dataset: Gun Action Recognition (GAR)
- Entrenamiento: Google Colab Pro + Google Drive
- LLM: [Claude API](https://www.anthropic.com) (Anthropic)
- Lenguaje: Python 3

---

## Estado del proyecto

- [x] Stage 1 — Segmentación de personas
- [x] Stage 2 — Detección de arma (Modelo A + Modelo B)
- [x] Stage 3 — Human Pose Estimation
- [x] Stage 4 — Análisis de intención (LLM) — validado, pendiente evaluación completa
- [ ] Redacción de la memoria TFM
