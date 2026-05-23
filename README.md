<h1 align="center">
  Detección de Amenazas Armadas en Vídeo
</h1>

<p align="center">
  <b>Pipeline multi-etapa de Deep Learning para videovigilancia</b><br>
  Trabajo Final de Máster · Ciencia de Datos · Universitat Oberta de Catalunya
</p>

<p align="center">
  <b>Autor:</b> Oliver Legarreta García &nbsp;·&nbsp;
  <b>Director:</b> Miguel Alejandro Ponce Proaño &nbsp;·&nbsp;
  <b>Junio 2026</b>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/OliverLegarretaUOC/tfm-threat-detection/main/results/demo/demo_pipeline.gif" alt="Demo del pipeline completo" width="720">
</p>

---

## Descripción

Sistema de detección de amenazas armadas en vídeo de vigilancia que integra cuatro modelos de Deep Learning en un pipeline secuencial. El sistema detecta armas, analiza la postura corporal del individuo y evalúa la intención mediante un modelo de lenguaje grande (LLM), operando bajo un esquema de **doble nivel de alerta** que permite configurar el compromiso entre sensibilidad y precisión según el contexto de despliegue.

La evaluación se realiza sobre el dataset [Gun Action Recognition (GAR)](https://doi.org/10.1016/j.dib.2024.110030) (258 clips: 140 positivos, 118 negativos con 12 categorías de actividades cotidianas).

---

## Arquitectura del pipeline

```
                          ┌─────────────────────────────────────────────┐
                          │              Vídeo de entrada               │
                          └──────────────────────┬──────────────────────┘
                                                 │
                                                 ▼
                   ┌─────────────────────────────────────────────────────┐
                   │  Etapa 1 — Segmentación de personas                │
                   │  YOLOv8s-seg (COCO pretrained)                     │
                   └──────────────────────┬──────────────────────────────┘
                                          │
                                          ▼
                   ┌─────────────────────────────────────────────────────┐
                   │  Etapa 2 — Detección de armas                      │
                   │  YOLOv8m fine-tuned (Modelo B, negativos COCO)      │──── Alerta Nivel 1
                   └──────────────────────┬──────────────────────────────┘
                                          │
                                          ▼
                   ┌─────────────────────────────────────────────────────┐
                   │  Etapa 3 — Estimación de pose corporal (HPE)       │
                   │  YOLOv8x-pose (keypoints COCO 5–10, tren superior) │──── Alerta Nivel 2
                   └──────────────────────┬──────────────────────────────┘
                                          │
                                          ▼
                   ┌─────────────────────────────────────────────────────┐
                   │  Etapa 4 — Análisis de intención (LLM)             │
                   │  Claude API (claude-sonnet-4-20250514)              │
                   └─────────────────────────────────────────────────────┘
```

**Doble nivel de alerta:**
- **Nivel 1:** arma detectada en ≥5 frames → alta sensibilidad (recall = 0,886)
- **Nivel 2:** Nivel 1 + postura de apuntado confirmada por HPE → alta precisión (precisión = 0,783)

---

## Resultados principales

### Comparativa de modelos de detección (Etapa 2)

Evaluación clip-level sobre el GAR test set (258 clips, CONF = 0,25, umbral = 5 frames):

| Modelo | Arquitectura | Negativos | mAP@50 | F1 | Precisión | Recall | FP | FN |
|--------|-------------|-----------|--------|-----|-----------|--------|----|----|
| A (base) | YOLOv8m | — | 0,626 | 0,720 | 0,575 | 0,964 | 100 | 5 |
| **B (producción)** | **YOLOv8m** | **~3.000 COCO** | **0,779** | **0,795** | **0,721** | **0,886** | **48** | **16** |
| C (seg-inicial) | YOLOv8m-seg | 108 LVIS | 0,105 | 0,796 | 0,701 | 0,921 | 55 | 11 |
| D (seg-ampliado) | YOLOv8m-seg | LVIS + Open Images | 0,046 | 0,702 | 0,575 | 0,900 | 93 | 14 |

El **Modelo B** se selecciona como detector de producción. La incorporación de negativos difíciles de COCO reduce las falsas alarmas un **52 %** respecto al Modelo A.

### Impacto del módulo HPE (Etapa 3)

| Configuración | Precisión | Recall | F1 | FP | FN |
|---|---|---|---|---|---|
| Nivel 1 (solo detector) | 0,721 | 0,886 | 0,795 | 48 | 16 |
| Nivel 2 (detector + HPE) | 0,783 | 0,721 | 0,751 | 28 | 39 |

Reducción adicional de falsas alarmas del **41,7 %**, concentrada en categorías de uso de teléfono con brazo extendido (N7, N8, N9).

---

## Estructura del repositorio

```
tfm-threat-detection/
│
├── notebooks/
│   ├── 0_data_preparation/                        # Preparación de datos
│   │   ├── 01_build_detection_dataset.ipynb       # Dataset de detección (Roboflow)
│   │   ├── 02_coco_hard_negatives.ipynb           # Negativos difíciles de COCO
│   │   ├── 03_gar_evaluation_splits.ipynb         # Splits de evaluación GAR
│   │   ├── 04_gar_negative_splits.ipynb           # Split de clips negativos GAR
│   │   ├── 05_lvis_negatives.ipynb                # Negativos LVIS (Modelo C)
│   │   └── 06_openimages_negatives.ipynb          # Negativos Open Images (Modelo D)
│   │
│   ├── 1_weapon_detection/                        # Etapa 2: detección de armas
│   │   ├── 01_train_modelo_A_B.ipynb              # Entrenamiento Modelos A y B
│   │   ├── 02_post_training_analysis.ipynb        # Curvas de entrenamiento y análisis
│   │   ├── 03_evaluation_clip_level.ipynb         # Evaluación clip-level Modelo B
│   │   ├── 04_train_modelo_C_seg.ipynb            # Entrenamiento Modelo C (YOLOv8m-seg)
│   │   ├── 05_eval_modelo_C_seg.ipynb             # Evaluación Modelo C
│   │   ├── 06_train_modelo_D_seg.ipynb            # Entrenamiento Modelo D (YOLOv8m-seg)
│   │   ├── 07_eval_modelo_D_seg.ipynb             # Evaluación Modelo D
│   │   └── 08_detection_vs_segmentation.ipynb     # Comparativa detección vs segmentación
│   │
│   ├── 2_segmentation_ablation/                   # Ablación de preproceso
│   │   ├── 01_bbox_padding_ablation.ipynb         # Configs FC / R10 / R20 / R30
│   │   ├── 02_pixel_mask_eval.ipynb               # Config MP (máscara de píxel)
│   │   └── 03_sam2_experiment.ipynb               # Experimento SAM2
│   │
│   ├── 3_pose_estimation/                         # Etapa 3: HPE
│   │   ├── 01_pose_exploration.ipynb              # Exploración visual y ángulos
│   │   └── 02_pose_temporal_eval.ipynb            # Evaluación Nivel 2 (det. + HPE)
│   │
│   ├── 4_intent_analysis/                         # Etapa 4: LLM
│   │   └── 01_llm_intent_analysis.ipynb           # Análisis de intención con Claude
│   │
│   └── 5_visualization/                           # Demos y visualización
│       ├── 01_demo_video.ipynb                    # Vídeo demo anotado
│       ├── 02_side_by_side.ipynb                  # Visualización comparativa
│       └── 03_final_comparison.ipynb              # Comparativa global de configuraciones
│
├── results/
│   ├── weapon_detection/          # Métricas y curvas Modelos A/B
│   ├── eval_modelo_c/             # Resultados Modelo C
│   ├── eval_modelo_d/             # Resultados Modelo D
│   ├── seg_ablation/              # Ablación FC/MP/R10/R20/R30
│   ├── sam2_ablation/             # Experimento SAM2
│   ├── pose/                      # Métricas Nivel 1 vs Nivel 2
│   └── demo/                      # GIF y vídeo demo
│
├── requirements.txt
├── .gitignore
└── README.md
```

> **Nota sobre los pesos del modelo:** los archivos `.pt` no se incluyen en el repositorio por su tamaño. Están disponibles bajo petición al autor.

---

## Datasets utilizados

| Dataset | Uso | Referencia |
|---------|-----|------------|
| [CS 231N (Roboflow)](https://universe.roboflow.com/dana-q9plh/cs-231n-project) | Entrenamiento del detector (positivos) | Roboflow Universe |
| [COCO](https://cocodataset.org) | Negativos difíciles (~3.000 imág.) + pesos preentrenados | Lin et al., 2014 |
| [GAR](https://doi.org/10.1016/j.dib.2024.110030) | Evaluación principal (258 clips) | Ruiz-Santaquiteria et al., 2024 |
| [J-HMDB](https://jhmdb.is.tue.mpg.de) | Validación módulo de detección de disparos (55 clips) | Jhuang et al., 2013 |
| [LVIS](https://www.lvisdataset.org) / [Open Images V7](https://storage.googleapis.com/openimages/web/index.html) | Negativos explorados para modelos de segmentación | — |

Los datasets no se incluyen en este repositorio. Consultar los enlaces para acceso.

---

## Reproducibilidad

### Requisitos

```bash
pip install -r requirements.txt
```

Los notebooks están diseñados para ejecutarse en **Google Colab Pro** con GPU NVIDIA T4. Los pesos del modelo y los datasets se leen desde Google Drive bajo la ruta `TFM/`.

### Carga del modelo en Colab

```python
from google.colab import drive
drive.mount('/content/drive')

# Copiar pesos localmente para evitar errores de conexión con Drive
import shutil
shutil.copy2(
    '/content/drive/MyDrive/TFM/experiments/weapon_det/yolov8m_weapons_B_e50_640/weights/best.pt',
    '/content/weapon_best.pt'
)

from ultralytics import YOLO
model = YOLO('/content/weapon_best.pt')
```

> Si se produce un error `OSError/ConnectionAbortedError [Errno 103]`, volver a montar Drive con `drive.mount('/content/drive', force_remount=True)`.

---

## Tecnologías

| Componente | Tecnología |
|-----------|-----------|
| Detección y segmentación | [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics) |
| Segmentación de objetos | [SAM2 (Meta AI)](https://github.com/facebookresearch/sam2) |
| Análisis de intención (LLM) | [Claude API](https://docs.anthropic.com) · `claude-sonnet-4-20250514` |
| Entorno de ejecución | Google Colab Pro (GPU T4) + Google Drive |
| Lenguaje | Python 3.10+ |

---

## Referencias

- Ruiz-Santaquiteria, J. et al. (2024). *Firearm-related action recognition and object detection dataset for video surveillance systems*. Data in Brief, 52, 110030. [DOI](https://doi.org/10.1016/j.dib.2024.110030)
- Jocher, G. et al. (2023). *Ultralytics YOLOv8*. [GitHub](https://github.com/ultralytics/ultralytics)
- Lin, T.-Y. et al. (2014). *Microsoft COCO: Common Objects in Context*. ECCV. [DOI](https://doi.org/10.1007/978-3-319-10602-1_48)
- Berardini, D. et al. (2023). *A deep-learning framework for handgun and knife detection from indoor video-surveillance cameras*. Multimedia Tools and Applications. [DOI](https://doi.org/10.1007/s11042-023-16231-x)
- Spence, R. et al. (2024). *Content moderator mental health, secondary trauma, and well-being*. Cyberpsychology, Behavior, and Social Networking, 27(2). [DOI](https://doi.org/10.1089/cyber.2023.0298)
- Jhuang, H. et al. (2013). *Towards Understanding Action Recognition*. ICCV. [DOI](https://doi.org/10.1109/ICCV.2013.396)

---

## Licencia

Este repositorio contiene código desarrollado como parte de un Trabajo Final de Máster académico en la Universitat Oberta de Catalunya. Los modelos y frameworks de terceros (YOLOv8, SAM2, Claude API) están sujetos a sus respectivas licencias.
