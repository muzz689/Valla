#!/bin/bash
START_LINE=$1
END_LINE=$2
#experiment_commands_AA_CCAT50_val.txt
#experiment_commands_AA_imdb_val.txt
#experiment_commands_AA_Guardian_val.txt
#exp_blogs.txt
COMMAND_FILE="Experiment_Commands/exp_blogs.txt"
FILENAME=$(basename "$COMMAND_FILE" .txt)

# Initialize a counter for the experiment number
EXP_NUMBER=$START_LINE

sed -n "${START_LINE},${END_LINE}p" "$COMMAND_FILE" | while IFS= read -r cmd; do
    echo "Processing Experiment Number: $EXP_NUMBER"
    
    # Append the experiment number to the command
    cmd="$cmd --exp_number $EXP_NUMBER"
    
    echo "Submitting command: $cmd"
    
    job_script=$(mktemp /tmp/job_script.XXXXXX.sh)
    cat << EOF > $job_script
#!/bin/bash
#SBATCH -p bigbatch
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH -J Exp_${EXP_NUMBER}
#SBATCH -o /home-mscluster/msakhidas/Valla/valla/methods/Experiment_outputs/${FILENAME}/exp_out_slurm.%N.%j.out
#SBATCH -e /home-mscluster/msakhidas/Valla/valla/methods/Experiment_outputs/${FILENAME}/exp_err_slurm.%N.%j.err
#SBATCH --exclude=mscluster[47,60,62,69,74,78,79,80,81,82,64,42,43,44,45,46,48,49,50,51,52,55,59,83,65,68,75,76,77]

# Export SLURM_JOB_ID for logging
export SLURM_JOB_ID

# Print the command for debugging
echo "Executing command: $cmd"

# Run the command
$cmd 
EOF

    job_id=$(sbatch $job_script | awk '{print $4}')
    echo "Submitted job ID: $job_id for Experiment Number: $EXP_NUMBER"
    
    rm $job_script
    
    # Increment the experiment number for the next iteration
    ((EXP_NUMBER++))
done
