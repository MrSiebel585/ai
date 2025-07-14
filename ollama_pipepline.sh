#!/bin/bash
# Author: @mrubuntuman - ForwardFartherFaster
# Title: Ollama Script Refactoring Pipeline
# Location: /opt/omniscient/init/init.ollama_refactor_pipeline.sh

# SETTINGS
INPUT_DIR="/opt/omniscient/init"
OUTPUT_DIR="/opt/omniscient/init_refactored"
LOG_FILE="${OUTPUT_DIR}/refactor_log.txt"
OLLAMA_MODEL="tinyllama"  # Change to your model (e.g., smolllm, wizardcoder)

# Ensure Ollama CLI is available
if ! command -v ollama &>/dev/null; then
    echo "[!] Error: ollama CLI not found. Exiting."
    exit 1
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

echo "[+] Refactor job started: $(date)" > "$LOG_FILE"

# MAIN LOOP
for script in "${INPUT_DIR}"/init*; do
    [ -f "$script" ] || continue  # Skip if not a file

    script_name="$(basename "$script")"
    echo "[+] Refactoring: $script_name" | tee -a "$LOG_FILE"

    # Run Ollama and capture output
    RESPONSE=$(cat <<EOF | ollama run "$OLLAMA_MODEL"
You are a code refactoring assistant. Please clean up, standardize, and improve readability of the following Bash script. Keep logic intact. Output only the improved script content.

--- BEGIN SCRIPT ---
$(cat "$script")
--- END SCRIPT ---
EOF
)

    if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
        echo "[!] Failed to refactor: $script_name" | tee -a "$LOG_FILE"
        continue
    fi

    # Save output
    outfile="${OUTPUT_DIR}/${script_name}"
    echo "$RESPONSE" > "$outfile"

    echo "[✔] Saved refactored script to: $outfile" | tee -a "$LOG_FILE"
done

echo "[✓] All scripts processed: $(date)" | tee -a "$LOG_FILE"

