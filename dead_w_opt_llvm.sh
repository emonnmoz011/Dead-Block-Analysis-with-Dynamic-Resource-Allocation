#!/bin/bash

# Set the directory where the batch files are located
BASE_DIR="/home/ysx4/hpc@scale/with_opt_llvm"
mkdir -p $BASE_DIR

# Define the paths to the tools
CSMITH_PATH="/usr/local/bin/csmith"
PROGRAM_MARKERS_PATH="/home/ysx4/program-markers/build/bin/program-markers"
CSMITH_INCLUDE_PATH="/usr/local/include"

# Clang versions and optimization flags
CLANG_VERSIONS=("clang-11" "clang-12" "clang-13" "clang-14")
OPT_FLAGS=("-O0" "-O1" "-O2" "-O3" "-Os")

# Start timing
start_time=$(date +%s)

# Generate Csmith C files and apply program markers in parallel
echo "Generating and applying markers to Csmith files in parallel..."
seq 1 5000 | parallel -j $(nproc) --bar $CSMITH_PATH ' > ' $BASE_DIR/test_{}.c ' && ' $PROGRAM_MARKERS_PATH --mode=dce $BASE_DIR/test_{}.c

# Function to compile files and analyze markers
compile_and_analyze() {
    local file=$1
    local clang=$2
    local opt=$3
    local output_file="${file%.*}_${clang}_${opt}.s"
    local analysis_output="${output_file%.*}_analysis.txt"

    echo "Compiling $file with $clang $opt"
    $clang $opt -S -I"$CSMITH_INCLUDE_PATH" -o "$output_file" "$file"
    
    if [ -s "$output_file" ]; then
        echo "$output_file generated successfully."
        # Analyze the assembly for marker calls
        echo "Analyzing for markers in $output_file"
        grep -o 'call[[:space:]]*DCEMarker[[:digit:]]*_' "$output_file" | wc -l > "$analysis_output"
        echo "Marker analysis written to $analysis_output"
    else
        echo "Failed to compile $output_file."
        return 1  # Indicate error
    fi
}

export -f compile_and_analyze

# Adjust jobs based on system load
adjust_jobs_based_on_load() {
    local current_load=$(uptime | awk -F 'load average:' '{ print $2 }' | cut -d',' -f1 | xargs)
    local max_load=$(nproc)  # Using number of processors as max load factor
    local jobs=$(echo "scale=2; ($max_load - $current_load) / 2" | bc)

    # Ensure minimum 1 job
    jobs=$(awk "BEGIN{print ($jobs<1)?1:int($jobs)}")

    echo $jobs
}

# Export necessary paths for GNU Parallel
export CSMITH_PATH PROGRAM_MARKERS_PATH CSMITH_INCLUDE_PATH

# Main execution loop with retry logic
max_retries=5
retry_count=0

while [ $retry_count -lt $max_retries ]; do
    jobs=$(adjust_jobs_based_on_load)
    echo "Running with $jobs parallel jobs."
    all_compiled_successfully=true
    for file in $BASE_DIR/test_*.c; do
        parallel -j "$jobs" compile_and_analyze ::: "$file" ::: "${CLANG_VERSIONS[@]}" ::: "${OPT_FLAGS[@]}" || all_compiled_successfully=false
    done

    if [ "$all_compiled_successfully" = true ]; then
        echo "All compilations and analyses completed successfully."
        break
    else
        echo "Some tasks failed, adjusting load parameters and retrying..."
        retry_count=$((retry_count+1))
        sleep 10  # Reduce system load
    fi
done

if [ $retry_count -eq $max_retries ]; then
    echo "Reached maximum retry limit without success."
fi

# Log the execution time
end_time=$(date +%s)
echo "Total execution time: $((end_time - start_time)) seconds."

echo "Compilation and analysis tasks completed."
