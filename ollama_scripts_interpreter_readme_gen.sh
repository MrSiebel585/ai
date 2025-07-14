#!/bin/bash
# 🧠 Omniscient Bash Interpreter + Ollama + README Generator

ROOT_DIR="/opt/omniscient"
LOG_DIR="$ROOT_DIR/logs/bash_analysis"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SESSION_LOG="$LOG_DIR/bash_session_$TIMESTAMP.log"
AI_FEEDBACK_LOG="$LOG_DIR/ollama_bash_feedback_$TIMESTAMP.md"
README_FILE="$ROOT_DIR/README_SCRIPTS_SUMMARY.md"
OLLAMA_MODEL="whiterabbitneo"

EXCLUDE_DIRS=("venv" "privategpt" "private-gpt" "__pycache__" "logs")

mkdir -p "$LOG_DIR"

# === Discover all eligible .sh scripts ===
mapfile -t bash_scripts < <(
  find "$ROOT_DIR" -type f -name "*.sh" | grep -Ev "$(IFS="|"; echo "${EXCLUDE_DIRS[*]}")"
)

# === Start Markdown files ===
echo "# 🔍 Ollama Bash Script Interpretation" > "$AI_FEEDBACK_LOG"
echo "_Generated on $TIMESTAMP_\n" >> "$AI_FEEDBACK_LOG"

echo "# 📜 Omniscient Bash Scripts Summary" > "$README_FILE"
echo "_Auto-generated using Ollama on $TIMESTAMP_" >> "$README_FILE"
echo >> "$README_FILE"

# === Run each script ===
for script in "${bash_scripts[@]}"; do
  RELATIVE_PATH="${script#$ROOT_DIR/}"
  SCRIPT_LOG="$LOG_DIR/$(echo "$RELATIVE_PATH" | tr '/' '_' | sed 's/.sh$//')_$TIMESTAMP.log"

  echo "▶️ Executing: $RELATIVE_PATH"
  
  {
    echo "=== Running: $RELATIVE_PATH ==="
    echo "Timestamp: $(date)"
    echo
    bash "$script"
    EXIT_CODE=$?
    echo
    echo "Exit Code: $EXIT_CODE"
  } &> "$SCRIPT_LOG"

  echo "[$(date)] $RELATIVE_PATH => Exit: $EXIT_CODE" >> "$SESSION_LOG"

  # === Feed output to Ollama ===
  echo -e "\n## 🔧 Script: \`$RELATIVE_PATH\`\n" >> "$AI_FEEDBACK_LOG"
  echo -e "### ⌨️ Raw Output:\n\`\`\`bash" >> "$AI_FEEDBACK_LOG"
  cat "$SCRIPT_LOG" >> "$AI_FEEDBACK_LOG"
  echo -e "\`\`\`\n" >> "$AI_FEEDBACK_LOG"

  echo -e "### 🧠 AI Interpretation:\n" >> "$AI_FEEDBACK_LOG"

  AI_RESULT=$(ollama run "$OLLAMA_MODEL" <<EOF
You are a senior Linux scripting expert. The following is the raw output from a Bash script located at $RELATIVE_PATH. Interpret the output and explain in plain English what the script is doing. Summarize it in a short paragraph appropriate for a README file.

$(cat "$SCRIPT_LOG")
EOF
)

  echo "$AI_RESULT" >> "$AI_FEEDBACK_LOG"
  echo -e "\n---\n" >> "$AI_FEEDBACK_LOG"

  # === Append to README summary ===
  echo "## \`$RELATIVE_PATH\`" >> "$README_FILE"
  echo "$AI_RESULT" | sed 's/^/> /' >> "$README_FILE"
  echo >> "$README_FILE"
done

echo -e "\n✅ Bash script analysis complete."
echo "📄 Ollama Markdown: $AI_FEEDBACK_LOG"
echo "📘 README Summary: $README_FILE"

