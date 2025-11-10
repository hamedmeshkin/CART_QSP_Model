#!/bin/bash
#SBATCH --account=CDERID0047
#SBATCH -J JobName          		  # Job name
#SBATCH -o logfiles/JobName_%j.out    # Standard output and error log (%x = job name, %j = job ID)
#SBATCH -e logfiles/JobName_%j.err    # Error log
#SBATCH --array=1-60                 # Job array index; the same number of real patients
####SBATCH --cpus-per-task=1    	  # Use # of CPU cores per task
#SBATCH --ntasks-per-node=20		  # Number of workers
#SBATCH --mem=10GB           		  # Each array runs one patient, so not much memory needed
#SBATCH --time=8:00:00      		  # Time limit (24 hours)

echo "Running on node $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "Task ID: $SLURM_ARRAY_TASK_ID"
echo "Job Name" : $SLURM_JOB_NAME

source /projects01/mikem/applications/R-4.4.1/set_env.sh
export R_LIBS="/home/lizhi/R_packages/4.4"


Rscript fitting.R -a "L02" -c 32 -l 512 -f -m 512 -t 0.001 >& logfiles/"$SLURM_JOB_NAME".o"$SLURM_JOB_ID"."$SLURM_ARRAY_TASK_ID".txt
