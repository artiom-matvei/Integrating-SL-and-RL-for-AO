1. `conda create -n integrating-sl-rl-for-ao python=3.8.13 -y`
2. `module load miniconda/3`
3. `module load cuda/11.6`
4. `conda activate integrating-sl-rl-for-ao`
5. `conda install -c compass compass==5.2.1 -y`
5. `conda run -n integrating-sl-rl-for-ao conda list compass`
6. `conda run -n integrating-sl-rl-for-ao pip install gym==0.26.2`
7. `conda run -n integrating-sl-rl-for-ao pip install torch==2.0.1+cu117 torchvision==0.15.2+cu117 torchaudio==2.0.2+cu117 --index-url https://download.pytorch.org/whl/cu117`
8. `export MAIN_DIR=$(pwd)` # This is the directory of the repository
9. `export PYTHONPATH=$MAIN_DIR:$PYTHONPATH`
10. `export SHESHA_ROOT=$MAIN_DIR/shesha`
11. `export PYTHONPATH=$SHESHA_ROOT:$PYTHONPATH`
