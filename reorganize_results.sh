#!/bin/bash
# ============================================================================
# reorganize_results.sh
#
# Reorganiza la carpeta results/ para alinearla con la estructura de
# notebooks/ y usar los nombres de la memoria (base, enriquecido, etc.)
#
# Ejecutar desde la raíz del repositorio:
#   cd tfm-threat-detection
#   bash reorganize_results.sh
#   git add -A && git commit -m "refactor: reorganizar results con nombres de la memoria"
#   git push
# ============================================================================

set -e

echo "=== Creando estructura de carpetas ==="
mkdir -p results/1_weapon_detection/modelo_base
mkdir -p results/1_weapon_detection/modelo_enriquecido
mkdir -p results/1_weapon_detection/modelo_seg_inicial
mkdir -p results/1_weapon_detection/modelo_seg_ampliado
mkdir -p results/2_segmentation_ablation/bbox_padding
mkdir -p results/2_segmentation_ablation/sam2
mkdir -p results/3_pose_estimation

echo "=== Moviendo archivos ==="

# --- 1_weapon_detection ---
echo "  [1] Weapon detection..."

# Modelo base (A)
git mv results/weapon_detection/plots/results_modeloA.png \
       results/1_weapon_detection/modelo_base/training_curves.png
git mv results/weapon_detection/plots/confusion_matrix_modeloA.png \
       results/1_weapon_detection/modelo_base/confusion_matrix.png

# Modelo enriquecido (B)
git mv results/weapon_detection/plots/results_modeloB.png \
       results/1_weapon_detection/modelo_enriquecido/training_curves.png
git mv results/weapon_detection/plots/confusion_matrix_modeloB.png \
       results/1_weapon_detection/modelo_enriquecido/confusion_matrix.png
git mv results/weapon_detection/training_curves_modeloB.csv \
       results/1_weapon_detection/modelo_enriquecido/training_curves.csv
git mv results/weapon_detection/evaluation_results_B.txt \
       results/1_weapon_detection/modelo_enriquecido/evaluation_results.txt

# Modelo seg-inicial (C)
git mv results/eval_modelo_c/clip_results_modelo_c.csv \
       results/1_weapon_detection/modelo_seg_inicial/clip_results.csv
git mv results/eval_modelo_c/clip_results_modelo_c.txt \
       results/1_weapon_detection/modelo_seg_inicial/evaluation_results.txt

# Modelo seg-ampliado (D)
git mv results/eval_modelo_d/clip_results_modelo_d.csv \
       results/1_weapon_detection/modelo_seg_ampliado/clip_results.csv
git mv results/eval_modelo_d/clip_results_modelo_d.txt \
       results/1_weapon_detection/modelo_seg_ampliado/evaluation_results.txt

# --- 2_segmentation_ablation ---
echo "  [2] Segmentation ablation..."

# Bbox padding configs
git mv results/seg_ablation/results_config_A_sin_seg.txt \
       results/2_segmentation_ablation/bbox_padding/results_FC.txt
git mv results/seg_ablation/results_config_B_con_seg.txt \
       results/2_segmentation_ablation/bbox_padding/results_MP.txt
git mv results/seg_ablation/results_config_C10_bbox_pad10.txt \
       results/2_segmentation_ablation/bbox_padding/results_R10.txt
git mv results/seg_ablation/results_config_C20_bbox_pad20.txt \
       results/2_segmentation_ablation/bbox_padding/results_R20.txt
git mv results/seg_ablation/results_config_C30_bbox_pad30.txt \
       results/2_segmentation_ablation/bbox_padding/results_R30.txt
git mv results/seg_ablation/C1_metricas_globales.png \
       results/2_segmentation_ablation/bbox_padding/metricas_globales.png
git mv results/seg_ablation/C2_fp_por_categoria.png \
       results/2_segmentation_ablation/bbox_padding/fp_por_categoria.png
git mv results/seg_ablation/C3_evolucion_padding.png \
       results/2_segmentation_ablation/bbox_padding/evolucion_padding.png
git mv results/seg_ablation/C3_scatter_frames.png \
       results/2_segmentation_ablation/bbox_padding/scatter_frames.png

# SAM2
git mv results/sam2_ablation/clip_results_SAM2.csv \
       results/2_segmentation_ablation/sam2/clip_results.csv
git mv results/sam2_ablation/results_config_SAM2.txt \
       results/2_segmentation_ablation/sam2/evaluation_results.txt
git mv results/sam2_ablation/fig1_metricas_clip.png \
       results/2_segmentation_ablation/sam2/metricas_clip.png
git mv results/sam2_ablation/fig2_fp_fn_totales.png \
       results/2_segmentation_ablation/sam2/fp_fn_totales.png
git mv results/sam2_ablation/fig3_fp_por_categoria.png \
       results/2_segmentation_ablation/sam2/fp_por_categoria.png

# --- 3_pose_estimation ---
echo "  [3] Pose estimation..."
git mv results/pose/clip_results.csv \
       results/3_pose_estimation/clip_results.csv
git mv results/pose/pose_temporal_results.txt \
       results/3_pose_estimation/evaluation_results.txt

# --- demo (se queda donde está, solo limpieza) ---
echo "  [demo] Sin cambios"

# --- Limpiar carpetas vacías y .gitkeep ---
echo "=== Limpiando carpetas vacías ==="
rm -f results/.gitkeep 2>/dev/null
rm -f results/eval_modelo_c/.gitkeep 2>/dev/null
rm -f results/eval_modelo_d/.gitkeep 2>/dev/null
rm -f results/sam2_ablation/.gitkeep 2>/dev/null
rm -f results/seg_ablation/.gitkeep 2>/dev/null

rmdir results/weapon_detection/plots 2>/dev/null || true
rmdir results/weapon_detection 2>/dev/null || true
rmdir results/eval_modelo_c 2>/dev/null || true
rmdir results/eval_modelo_d 2>/dev/null || true
rmdir results/sam2_ablation 2>/dev/null || true
rmdir results/seg_ablation 2>/dev/null || true
rmdir results/pose 2>/dev/null || true

echo ""
echo "=== Reorganización completada ==="
echo ""
echo "Estructura final:"
find results/ -type f | sort
echo ""
echo "Siguiente paso:"
echo "  git add -A"
echo "  git commit -m 'refactor: reorganizar results con nombres de la memoria'"
echo "  git push"
