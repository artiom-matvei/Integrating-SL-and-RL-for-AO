#!/bin/bash
#SBATCH --job-name=unet_train
#SBATCH --output=data/slurm/unet_train_%j.out
#SBATCH --error=data/slurm/unet_train_%j.err
#SBATCH --gpus=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --partition=long

# Check if mode argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: sbatch $0 <mode>"
    echo "Available modes:"
    echo "  collect  - Collect training data"
    echo "  train    - Train the U-Net"
    echo "  test     - Test U-Net in closed loop"
    exit 1
fi

MODE=$1

# Activate your conda environment if you're using one
source ~/.bashrc
module load miniconda/3
module load cuda/11.6
conda activate integrating-sl-rl-for-ao  # adjust this to your environment name

# CD to your project directory
# ASSUMES YOU CLONED THE REPO TO THE SCRATCH DIRECTORY
SCRATCH_USERNAME_PATH="m/matveia"
cd /network/scratch/${SCRATCH_USERNAME_PATH}/Integrating-SL-and-RL-for-AO

export MAIN_DIR=$(pwd)
export PYTHONPATH=$MAIN_DIR:$PYTHONPATH
export SHESHA_ROOT=$MAIN_DIR/shesha
export PYTHONPATH=$SHESHA_ROOT:$PYTHONPATH

export BATCH_SIZE=64
export PARAMETER_FILE="pyr_40x40_8m_gs_0_n3.py"
export DATASET_NAME="mag_0"
export EXPERIMENT_NAME="fix_unet_not_ampere_L1_relative"

# Run the appropriate command based on mode
case $MODE in
    "collect")
        python src/mains/mains_unet/main_recollect_data.py \
            --parameter_file $PARAMETER_FILE \
            --dataset_name $DATASET_NAME
        ;;
    "train")
        python src/mains/mains_unet/main_train.py \
            --experiment_name $EXPERIMENT_NAME \
            --data_name $DATASET_NAME \
            --criterion "L1_relative" \
            --use_voltage_as_phase \
            --batch_size $BATCH_SIZE \
        ;; # the test_L1_relative comes from the combination of experiment_name and criterion
    "test") # before running test, make sure to test_gains first
        python src/mains/mains_unet/main_closed_loop_unet.py \
            --parameter_file $PARAMETER_FILE \
            --device 0 \
            --unet_dir $EXPERIMENT_NAME \
            --unet_name "100_net_fix_unet_not_ampere_L1_relative.pth" \
            --normalization_noise_unet \
            --normalization_noise_value_unet 0 
        ;;
    "test_gains")
        python src/mains/mains_unet/main_closed_loop_unet.py \
            --parameter_file $PARAMETER_FILE \
            --device 0 \
            --unet_dir "fix_unet_not_ampere_L1_relative" \
            --unet_name "100_net_fix_unet_not_ampere_L1_relative.pth" \
            --normalization_noise_unet \
            --normalization_noise_value_unet 0 \
            --test_gains
        ;;
    *)
        echo "Error: Invalid mode '$MODE'"
        echo "Available modes: collect, train, test"
        exit 1
        ;;
esac