#!/bin/bash
#SBATCH --account=CDERID0047
#SBATCH -J DataProccessing          		  # Job name
#SBATCH -o logfiles/Band_%j.out    # Standard output and error log (%x = job name, %j = job ID)
#SBATCH -e logfiles/Band_%j.err    # Error log
####SBATCH --cpus-per-task=1    	  # Use # of CPU cores per task
#SBATCH --ntasks-per-node=1		  # Number of workers
#SBATCH --mem=10GB           		  # Each array runs one patient, so not much memory needed
#SBATCH --time=1:00:00      		  # Time limit (24 hours)

echo "Running on node $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "Task ID: $SLURM_ARRAY_TASK_ID"
echo "Job Name" : $SLURM_JOB_NAME
echo "Number of cores" :  $SLURM_NTASKS_PER_NODE

source /projects01/mikem/applications/R-4.4.1/set_env.sh
export R_LIBS="/home/lizhi/R_packages/4.4"

Rscript DataProccessing.R   >& logfiles/"$SLURM_JOB_NAME".o"$SLURM_JOB_ID".txt
