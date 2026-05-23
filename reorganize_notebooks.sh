#!/bin/bash
set -e

echo "=== Creando estructura de carpetas ==="
mkdir -p notebooks/0_data_preparation
mkdir -p notebooks/1_weapon_detection
mkdir -p notebooks/2_segmentation_ablation
mkdir -p notebooks/3_pose_estimation
mkdir -p notebooks/4_intent_analysis
mkdir -p notebooks/5_visualization

echo "=== Moviendo notebooks ==="

echo "  [0] Data preparation..."
git mv notebooks/01_procesar_dataset.ipynb notebooks/0_data_preparation/01_build_detection_dataset.ipynb
git mv "notebooks/utils/00_añadir_coco_weapons_dataset.ipynb" notebooks/0_data_preparation/02_coco_hard_negatives.ipynb
git mv notebooks/utils/07_conjunto_evaluacion_estable.ipynb notebooks/0_data_preparation/03_gar_evaluation_splits.ipynb
git mv notebooks/utils/09_crear_split_no_gun.ipynb notebooks/0_data_preparation/04_gar_negative_splits.ipynb
git mv notebooks/23_lvis_negatives.ipynb notebooks/0_data_preparation/05_lvis_negatives.ipynb
git mv notebooks/26_openimages_negatives_v2.ipynb notebooks/0_data_preparation/06_openimages_negatives.ipynb

echo "  [1] Weapon detection..."
git mv notebooks/02_entrenamiento.ipynb notebooks/1_weapon_detection/01_train_modelo_A_B.ipynb
git mv notebooks/03_post_entrenamiento.ipynb notebooks/1_weapon_detection/02_post_training_analysis.ipynb
git mv notebooks/10_evaluacion.ipynb notebooks/1_weapon_detection/03_evaluation_clip_level.ipynb
git mv notebooks/24_train_modelo_c.ipynb notebooks/1_weapon_detection/04_train_modelo_C_seg.ipynb
git mv notebooks/25_eval_modelo_c.ipynb notebooks/1_weapon_detection/05_eval_modelo_C_seg.ipynb
git mv notebooks/27_train_modelo_d.ipynb notebooks/1_weapon_detection/06_train_modelo_D_seg.ipynb
git mv notebooks/28_eval_modelo_d.ipynb notebooks/1_weapon_detection/07_eval_modelo_D_seg.ipynb
git mv notebooks/16_seg_comparison.ipynb notebooks/1_weapon_detection/08_detection_vs_segmentation.ipynb

echo "  [2] Segmentation ablation..."
git mv notebooks/17_bbox_padding_eval.ipynb notebooks/2_segmentation_ablation/01_bbox_padding_ablation.ipynb
git mv notebooks/15_seg_weapon_eval.ipynb notebooks/2_segmentation_ablation/02_pixel_mask_eval.ipynb
git mv notebooks/20_sam2_weapon_detection.ipynb notebooks/2_segmentation_ablation/03_sam2_experiment.ipynb

echo "  [3] Pose estimation..."
git mv notebooks/11_pose_exploration.ipynb notebooks/3_pose_estimation/01_pose_exploration.ipynb
git mv notebooks/12_pose_temporal_eval.ipynb notebooks/3_pose_estimation/02_pose_temporal_eval.ipynb

echo "  [4] Intent analysis..."
git mv notebooks/13_llm_intent_analysis.ipynb notebooks/4_intent_analysis/01_llm_intent_analysis.ipynb

echo "  [5] Visualization..."
git mv notebooks/14_demo_video.ipynb notebooks/5_visualization/01_demo_video.ipynb
git mv notebooks/22_visualizacion_sbs.ipynb notebooks/5_visualization/02_side_by_side.ipynb
git mv notebooks/21_comparativa_final.ipynb notebooks/5_visualization/03_final_comparison.ipynb

echo "=== Limpiando ==="
rm -f notebooks/utils/.gitkeep 2>/dev/null
rmdir notebooks/utils 2>/dev/null && echo "  utils/ eliminada" || echo "  utils/ no vacia, revisar"

echo ""
echo "=== Reorganizacion completada ==="
find notebooks/ -name "*.ipynb" | sort
echo ""
echo "Ahora ejecuta:"
echo "  git add -A"
echo "  git commit -m 'refactor: reorganizar notebooks en subcarpetas tematicas'"
echo "  git push"
