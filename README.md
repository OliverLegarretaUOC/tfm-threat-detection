# TFM — Deteccion de personas armadas y análisis de intención para evaluar situaciones de violencia en vídeo

**Máster en Ciencia de Datos · Universitat Oberta de Catalunya**

**Autor:** Oliver Legarreta García · **Tutor:** Miguel Alejandro Ponce Proaño

---

![Demo pipeline](https://raw.githubusercontent.com/OliverLegarretaUOC/tfm-threat-detection/main/results/demo/demo_pipeline.gif)

---

## Descripción

Sistema de detección de amenazas armadas en vídeo basado en visión por computador y deep learning. El pipeline combina múltiples modelos YOLOv8 en una arquitectura por etapas capaz de detectar armas, analizar la pose corporal y evaluar la intención del sujeto.

El sistema está diseñado sobre el dataset **CS 231 N (Roboflow)** (https://universe.roboflow.com/dana-q9plh/cs-231n-project) y se evalúa tanto a nivel de frame como a nivel de clip (258 clips: 140 positivos, 118 negativos) con el dataset de **Gun Action Recognition** (https://www.sciencedirect.com/science/article/pii/S2352340924000040)

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
[Stage 3] Estimación de pose (HPE)     — YOLOv8m-pose        →  Alerta Nivel 2
      │
      ▼
[Stage 4] Análisis de intención (LLM)  — Claude API (claude-sonnet-4-20250514)
```

El sistema implementa un **framework de doble nivel de alerta**:
- **Nivel 1:** arma detectada visualmente (Stage 2)
- **Nivel 2:** amenaza confirmada mediante análisis de pose y ángulo de brazo (Stage 3)

---

## Estructura del repositorio

```
tfm-threat-detection/
│
├── notebooks/
│   ├── utils/
│   │   ├── 00_coco_negatives.ipynb          # Construir negativos COCO para entrenamiento
│   │   ├── 07_stable_split.ipynb            # Crear splits train/val/test estratificados
│   │   └── 09_no_gun_split.ipynb            # Split de clips negativos GAR
│   ├── 01_dataset.ipynb                     # Construcción del dataset de detección
│   ├── 02_entrenamiento.ipynb               # Entrenamiento YOLOv8m (Modelo A y B)
│   ├── 03_post_entrenamiento.ipynb          # Análisis post-entrenamiento
│   ├── 10_evaluacion.ipynb                  # Evaluación cuantitativa Modelo B
│   ├── 11_pose_exploration.ipynb            # Exploración visual HPE
│   ├── 12_pose_temporal_eval.ipynb          # Evaluación cuantitativa HPE
│   ├── 13_llm_intent_analysis.ipynb         # Integración y validación LLM
│   └── 14_demo_video.ipynb                  # Generación de vídeo demo anotado
│
├── results/
│   ├── weapon_detection/
│   │   ├── plots/
│   │   │   ├── results_modeloA.png          # Curvas loss/mAP Modelo A
│   │   │   ├── results_modeloB.png          # Curvas loss/mAP Modelo B
│   │   │   └── confusion_matrix_modeloB.png
│   │   ├── training_curves_modeloA.csv      # Métricas de entrenamiento Modelo A
│   │   ├── training_curves_modeloB.csv      # Métricas de entrenamiento Modelo B
│   │   └── evaluation_results_B.txt         # Evaluación clip-level Modelo B
│   ├── pose/
│   │   ├── pose_temporal_results.txt        # Métricas comparativas B vs B+HPE
│   │   └── clip_results.csv                 # Resultados por clip con HPE
│   └── demo/
│       └── demo_PAH1_C1_P2_V1_HB_3.mp4     # Vídeo demo del pipeline completo
│
└── README.md
```

---

## Resultados principales

### Stage 2 — Detección de arma

| Modelo | mAP@50 | Precision | Recall | F1 (clip) | FP |
|--------|--------|-----------|--------|-----------|-----|
| Modelo A | 0.626 | 0.626 | 0.421 | 0.720 | 100 |
| **Modelo B** | **0.779** | **0.779** | **0.332** | **0.795** | **48** |

Modelo B entrenado añadiendo ~3.000 imágenes negativas de COCO al dataset original. Reducción de falsos positivos del **52%** respecto al Modelo A.

### Stage 3 — Human Pose Estimation

| | Modelo B | Modelo B + HPE | Δ |
|---|---|---|---|
| Accuracy | 0.752 | 0.819 | +0.068 |
| Precision | 0.721 | 0.861 | +0.140 |
| Recall | 0.886 | 0.721 | −0.164 |
| F1 | 0.795 | 0.784 | −0.011 |
| FP | 48 | 28 | **−41.7%** |
| FN | 16 | 39 | +23 |

La integración del módulo HPE reduce los falsos positivos en un **41.7%** adicional, con mayor impacto en categorías de personas sujetando teléfonos (N7: −57 pp, N9: −67 pp). El coste es un aumento de falsos negativos en clips de porte oculto donde el brazo no está extendido.

---

## Tecnologías

- **Modelos:** [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics)
- **Dataset:** Gun Action Recognition (GAR)
- **Entrenamiento:** Google Colab Pro (GPU T4) + Google Drive
- **LLM:** [Claude API](https://www.anthropic.com) (Anthropic)
- **Lenguaje:** Python 3

---
