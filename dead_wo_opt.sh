#!/bin/bash

# Set the directory where the batch files are located
BASE_DIR="/home/ysx4/hpc@scale/wo_opt"
mkdir -p $BASE_DIR

# Define the paths to the tools
CSMITH_PATH="/usr/local/bin/csmith"
PROGRAM_MARKERS_PATH="/home/ysx4/program-markers/build/bin/program-markers"
CSMITH_INCLUDE_PATH="/usr/local/include"

# GCC versions and optimization flags
GCC_VERSIONS=("gcc-9" "gcc-10" "gcc-11" "gcc-12")
OPT_FLAGS=("-O0" "-O1" "-O2" "-O3" "-Os")

# Start timing
start_time=$(date +%s)

# Generate Csmith C files and apply program markers sequentially
echo "Generating and applying markers to Csmith files sequentially..."
for i in {1..5000}; do
    FILE_NAME="${BASE_DIR}/test_${i}.c"
    $CSMITH_PATH > "$FILE_NAME"
    $PROGRAM_MARKERS_PATH --mode=dce "$FILE_NAME"
done

# Function to compile files and analyze markers
compile_and_analyze() {
    local file=$1
    local gcc=$2
    local opt=$3
    local output_file="${file%.*}_${gcc}_${opt}.s"
    local analysis_output="${output_file%.*}_analysis.txt"

    echo "Compiling $file with $gcc $opt"
    $gcc $opt -S -I"$CSMITH_INCLUDE_PATH" -o "$output_file" "$file"
    
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

# Compile each file with each GCC version and optimization flag
for file in $BASE_DIR/test_*.c; do
    for gcc in "${GCC_VERSIONS[@]}"; do
        for opt in "${OPT_FLAGS[@]}"; do
            compile_and_analyze "$file" "$gcc" "$opt"
        done
    done
done

# Log the execution time
end_time=$(date +%s)
echo "Total execution time: $((end_time - start_time)) seconds."

echo "Compilation and analysis tasks completed."
