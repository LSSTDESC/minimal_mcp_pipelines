#!/bin/bash -l
#SBATCH --qos=regular
#SBATCH -J desc-tutorial
#SBATCH -n 100
#SBATCH --cpus-per-task=1
#SBATCH --constraint=cpu
#SBATCH -t 03:00:00
#SBATCH -o lssty1shear.log
#SBATCH -e lssty1shear.error

# Put here the path to the desc tutorial repo location
cd $SCRATCH/desc/minimal_mcmc

# Load environment
source /global/cfs/cdirs/lsst/groups/MCP/setup-cosmology-dev.sh

# Run the chain
time srun cosmosis --mpi forecast_3x2pt.ini
