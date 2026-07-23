#!/bin/bash -l
#SBATCH --partition=milano
#SBATCH --account=rubin:developers
#SBATCH --job-name=mcmc_minimal
#SBATCH --nodes=7
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --time=06:00:00
#SBATCH --output=lssty1shear-%j.log
#SBATCH --error=lssty1shear-%j.error

# =============================================================================
# DESC tutorial LSST Y1 shear forecast — S3DF (Apptainer/OpenMPI)
# Converted from NERSC Perlmutter srun-based script
#
# Original: 100 MPI tasks via srun on Perlmutter
# S3DF:     100 MPI tasks via mpirun with Apptainer container
#           7 nodes x 16 tasks/node = 112 slots; -np 100 uses 100 of them
# =============================================================================

module load mpi/openmpi-x86_64

### START These 2 env variables may need to be updated for your copy of SIF and 
### minimal_mcmc

# This container includes firecrown 1.14.3
SIF=/sdf/data/desc/apptainer/desc-cosmology_slac-latest-2026-07-23.sif
# Path to the minimal_mcmc repo — update to your S3DF location
WORKDIR=$SCRATCH/minimal_mcmc

### END


ENTRYPOINT=/opt/desc/bin/s3df-entrypoint.sh
export FIRECROWN_DIR=/opt/desc/lib/python3.13/site-packages

# Verify SIF exists
if [ ! -f "$SIF" ]; then
    echo "ERROR: SIF not found at $SIF"
    exit 1
fi

cd $WORKDIR

# Suppress munge PMIx warning (munge not available inside container)
export PMIX_MCA_psec=native
export OMP_NUM_THREADS=1

echo "=== Job Info ==="
echo "Job ID:    $SLURM_JOB_ID"
echo "Nodes:     $SLURM_NODELIST"
echo "Tasks:     $SLURM_NTASKS"
echo "SIF:       $SIF"
echo "Workdir:   $WORKDIR"
echo ""

# Build host string with slot counts from Slurm allocation
HOST_STRING=$(scontrol show hostnames $SLURM_NODELIST | \
    awk -v slots=$SLURM_NTASKS_PER_NODE '{printf "%s:%s,", $1, slots}' | \
    sed 's/,$//')

echo "Host string: $HOST_STRING"
echo ""

# Run the chain
# -B binds S3DF filesystem directories in the container
# apptainer exec is used to execute a single command using
# the sif file defined in $SIF
# the container is iniialized using the $ENTRYPOINT script
time mpirun -np 100 --host $HOST_STRING \
    apptainer exec \
        -B /sdf/,/sdf/scratch,/fs,/lscratch \
        $SIF \
        $ENTRYPOINT \
        cosmosis --mpi forecast_3x2pt.ini
