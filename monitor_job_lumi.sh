#!/bin/bash -e
#SBATCH --job-name=fmf.hip
#SBATCH --account=project_465000096
#SBATCH --time=00:06:00
#SBATCH --partition=standard-g
#SBATCH --nodes=1
#SBATCH --mem=124G
#SBATCH --gpus-per-node=8
#SBATCH --cpus-per-task=8
#SBATCH -o %x-%j.out


# Define the monitoring function
gpu_monitoring() {
    local num_gpus=${SLURM_GPUS_PER_NODE}
    local node_name=$(hostname)
    local gpu_monitoring_file="gpu_monitoring_${SLURM_JOBID}_node_${node_name}.csv"

    rocm-smi --showuse --csv | head -n 1 > "$gpu_monitoring_file"
    # Perform monitoring until the primary job step completes
    while squeue -j ${SLURM_JOBID} &>/dev/null; do
        rocm-smi --csv --showuse --showmemuse | sed '1d;/^$/d' >> "$gpu_monitoring_file"
        sleep 30
    done
}

# Export function to be used across nodes
export -f gpu_monitoring

nodes_compressed="$(sacct --noheader -X -P -o NodeList --jobs=${SLURM_JOBID})"
echo nodes_compressed
echo $nodes_compressed

nodes="$(./expand_nodes.sh $nodes_compressed)"
echo nodes
echo $nodes
for node in $nodes; do
  srun --overlap --jobid="${SLURM_JOBID}" -w "$node" bash -c 'gpu_monitoring' &
done

# Start the primary job task with srun (make sure to tailor flags as needed)
srun ...
