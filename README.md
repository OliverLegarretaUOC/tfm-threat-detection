# TFM — Deteccion de personas armadas y análisis de intención para evaluar situaciones de violencia en vídeo

**Máster en Ciencia de Datos · Universitat Oberta de Catalunya**

**Autor:** Oliver Legarreta García · **Tutor:** Miguel Alejandro Ponce Proaño

---

![Demo pipeline](https://raw.githubusercontent.com/OliverLegarretaUOC/tfm-threat-detection/main/results/demo/demo_pipeline.gif)

---

## Descripción
 
Sistema de detección de amenazas armadas en vídeo basado en visión por computador y deep learning. El pipeline combina múltiples modelos YOLOv8 en una arquitectura por etapas capaz de detectar armas, analizar la pose corporal del sujeto y evaluar la intención mediante un LLM.
 
El sistema se entrena sobre el dataset **CS 231N (Roboflow)** y se evalúa a nivel de frame y de clip (258 clips: 140 positivos, 118 negativos) con el dataset **Gun Action Recognition (GAR)** (Ruiz-Santaquiteria et al., 2024).
 
---
 
## Arquitectura del pipeline (4 etapas)
 
```
Vídeo de entrada
      │
      ▼
[Stage 1] Segmentación de personas     — yolov8s-seg (COCO pretrained)
      │
      ▼
[Stage 2] Detección de arma            — yolov8m fine-tuned (Modelo B)  →  Alerta Nivel 1
      │
      ▼
[Stage 3] Estimación de pose (HPE)     — yolov8x-pose (keypoints 5–10)  →  Alerta Nivel 2
      │
      ▼
[Stage 4] Análisis de intención (LLM)  — Claude API (claude-sonnet-4-20250514)
```
 
El sistema implementa un **framework de doble nivel de alerta**:
- **Nivel 1:** arma detectada visualmente (alta sensibilidad, recall prioritario)
- **Nivel 2:** amenaza confirmada mediante análisis de pose y ángulo de brazo (alta precisión)
---
 
## Estructura del repositorio
 
```
tfm-threat-detection/
│
├── notebooks/
│   ├── utils/
│   │   ├── 00_coco_negatives.ipynb          # Construcción de negativos COCO para entrenamiento
│   │   ├── 07_stable_split.ipynb            # Splits train/val/test estratificados
│   │   └── 09_no_gun_split.ipynb            # Split de clips negativos GAR
│   ├── 01_procesar_dataset.ipynb            # Construcción del dataset de detección
│   ├── 02_entrenamiento.ipynb               # Entrenamiento YOLOv8m (Modelo A y B)
│   ├── 03_post_entrenamiento.ipynb          # Análisis post-entrenamiento y curvas
│   ├── 10_evaluacion.ipynb                  # Evaluación cuantitativa Modelo B (frame + clip)
│   ├── 11_pose_exploration.ipynb            # Exploración visual HPE sobre clips GAR
│   ├── 12_pose_temporal_eval.ipynb          # Evaluación cuantitativa pipeline B + HPE
│   ├── 13_llm_intent_analysis.ipynb         # Integración y validación Stage 4 LLM
│   ├── 14_demo_video.ipynb                  # Generación de vídeo demo anotado
│   ├── 15_seg_ablation_baseline.ipynb       # Ablación segmentación — Config A (baseline)
│   ├── 16_seg_ablation_configs.ipynb        # Ablación segmentación — Configs B, C10/C20/C30
│   ├── 17_seg_ablation_results.ipynb        # Análisis y comparativa ablación segmentación
│   ├── 18_shot_detection.ipynb              # Módulo de detección de disparos (kinematic)
│   ├── 19_seg_ablation_resumen.ipynb        # Resumen ablación para presentación al tutor
│   └── 20_sam2_weapon_detection.ipynb       # Experimento SAM2 como pre-procesado
│
├── results/
│   ├── weapon_detection/
│   │   ├── plots/
│   │   │   ├── results_modeloA.png          # Curvas loss/mAP Modelo A
│   │   │   ├── results_modeloB.png          # Curvas loss/mAP Modelo B
│   │   │   └── confusion_matrix_modeloB.png
│   │   ├── training_curves_modeloA.csv      # Métricas epoch a epoch Modelo A
│   │   ├── training_curves_modeloB.csv      # Métricas epoch a epoch Modelo B
│   │   └── evaluation_results_B.txt         # Evaluación clip-level Modelo B (mAP + F1)
│   ├── seg_ablation/
│   │   └── seg_ablation_summary.csv         # Comparativa configs A/B/C10/C20/C30
│   ├── pose/
│   │   ├── pose_temporal_results.txt        # Métricas B vs B+HPE
│   │   └── clip_results.csv                 # Resultados por clip con HPE
│   └── demo/
│       └── demo_PAH1_C1_P2_V1_HB_3.mp4     # Vídeo demo del pipeline completo
│
├── requirements.txt
├── .gitignore
└── README.md
```
 
---
 
## Resultados principales
 
### Stage 2 — Detección de arma (clip-level, umbral = 5 frames)
 
| Modelo | mAP@50 | Precision | Recall | F1 (clip) | FP | FN |
|--------|--------|-----------|--------|-----------|----|----|
| Modelo A | 0.626 | 0.626 | 0.421 | 0.720 | 100 | 5 |
| **Modelo B** | **0.779** | **0.779** | **0.332** | **0.795** | **48** | **16** |
 
El **Modelo B** incorpora ~3.000 imágenes negativas de COCO como hard negatives durante el entrenamiento. Esto supone una reducción de falsos positivos del **52%** respecto al Modelo A.
 
Categorías negativas con mayor tasa de FP en Modelo B:
 
| Categoría | Descripción | FP% |
|-----------|-------------|-----|
| N9 | Phone recording 2h | 77.8% |
| N8 | Phone recording 1h | 60.0% |
| N7 | Phone both hands | 57.1% |
| N6 | Phone looking | 50.0% |
 
El análisis indica que estos FP son errores de forma (el modelo reconoce la silueta del teléfono como arma) y no son corregibles únicamente ajustando el umbral de confianza — requieren intervención en el entrenamiento.
 
### Stage 3 — Human Pose Estimation (HPE)
 
| | Modelo B | Modelo B + HPE | Δ |
|---|---|---|---|
| Accuracy | 0.752 | 0.819 | +0.068 |
| Precision | 0.721 | 0.861 | +0.140 |
| Recall | 0.886 | 0.721 | −0.164 |
| F1 | 0.795 | 0.784 | −0.011 |
| FP | 48 | 28 | **−41.7%** |
| FN | 16 | 39 | +23 |
 
El módulo HPE clasifica la pose en tres estados: AIMING (ángulo ≥ 160°), HOLDING (100–159°) y NEUTRAL (< 100°). El aumento de FN se concentra en clips de porte oculto (PCH3/5/6/7) donde el brazo no está extendido, lo que es consistente con la naturaleza de esa clase.
 
### Ablación de segmentación (notebooks 15–17)
 
Se evaluaron cinco configuraciones para restringir la región de detección del arma:
 
| Config | Descripción | F1 | Δ vs baseline |
|--------|-------------|-----|----------------|
| A | Frame completo (baseline) | 0.7947 | — |
| B | Máscara de píxel (seg exacta) | 0.551 | −0.244 |
| C10 | Bounding box + padding 10% | 0.7947 | 0.000 |
| C20 | Bounding box + padding 20% | < A | − |
| C30 | Bounding box + padding 30% | < A | − |
 
**Decisión:** se mantiene el baseline (Config A, sin segmentación). La segmentación ayuda cuando el objeto confusor está alejado del cuerpo (N6 teléfono: −25 pp de FP; N11 bebiendo: −33 pp), pero perjudica cuando está próximo (N5 teléfono relajado: +40 pp de FP) porque el padding incluye el objeto confusor en la ROI. Config B degrada significativamente porque el arma puede extenderse más allá del contorno corporal.
 
### Experimento SAM2 (notebook 20)
 
Se evaluó `facebook/sam2.1-hiera-base-plus` como etapa de pre-procesado: segmentación por objetos antes de pasar cada segmento al detector de armas. Validación sobre 20 clips: 7/10 TP, 7/10 TN, tiempo medio de 67.3 s/clip. El experimento se documenta como exploración metodológica; los resultados completos y la decisión de inclusión/exclusión en el pipeline de producción se discuten en la memoria.
 
---
 
## Datasets
 
- **Entrenamiento del detector:** [CS 231N — Roboflow](https://universe.roboflow.com/dana-q9plh/cs-231n-project) + negativos de COCO (~3.000 imágenes)
- **Evaluación:** [Gun Action Recognition (GAR)](https://www.sciencedirect.com/science/article/pii/S2352340924000040) — Ruiz-Santaquiteria et al., 2024. 258 clips (140 positivos PAH/PCH, 118 negativos N1–N12)
- **Validación detección de disparos:** J-HMDB `shoot_gun` class (55 clips)
Los datasets no se incluyen en este repositorio. Consultar los enlaces para acceso.
 
---
 
## Reproducibilidad
 
### Requisitos
 
```bash
pip install -r requirements.txt
```
 
### Entorno
 
Los notebooks están diseñados para ejecutarse en **Google Colab Pro** con GPU T4. Los pesos del modelo y los datasets se leen desde Google Drive bajo la ruta `TFM/`.
 
Para montar Drive en Colab:
 
```python
from google.colab import drive
drive.mount('/content/drive')
```
 
Si se produce un error `OSError/ConnectionAbortedError [Errno 103]`, volver a montar con:
 
```python
drive.mount('/content/drive', force_remount=True)
```
 
### Pesos del modelo
 
Los pesos de Modelo B (`yolov8m_weapons_B_e50_640/weights/best.pt`) no se distribuyen en este repositorio por tamaño. Se copian localmente en Colab antes de cargar el modelo:
 
```python
import shutil
shutil.copy2('/content/drive/MyDrive/TFM/experiments/weapon_det/yolov8m_weapons_B_e50_640/weights/best.pt',
             '/content/weapon_best.pt')
model = YOLO('/content/weapon_best.pt')
```
 
---
 
## Tecnologías
 
- **Modelos:** [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics) (seg, detection, pose)
- **Segmentación de objetos:** [SAM2 — Meta AI](https://github.com/facebookresearch/sam2)
- **LLM:** [Claude API](https://www.anthropic.com) — `claude-sonnet-4-20250514` (Anthropic)
- **Entrenamiento:** Google Colab Pro (GPU T4) + Google Drive
- **Lenguaje:** Python 3
---
 
## Referencias
 
- Ruiz-Santaquiteria, J. et al. (2024). *Gun Action Recognition Dataset*. Data in Brief. https://doi.org/10.1016/j.dib.2024.110030
- Jocher, G. et al. (2023). *Ultralytics YOLOv8*. https://github.com/ultralytics/ultralytics
- Lin, T.-Y. et al. (2014). *Microsoft COCO: Common Objects in Context*. ECCV.
- Spence, N. et al. (2024). *Occupational Hazards of Content Moderation*. Cyberpsychology, Behavior, and Social Networking. https://doi.org/10.1089/cyber.2023.0298
---
 
## Licencia
 
Este repositorio contiene código desarrollado como parte de un Trabajo Fin de Máster académico. Los modelos de terceros (YOLOv8, SAM2) están sujetos a sus respectivas licencias.
