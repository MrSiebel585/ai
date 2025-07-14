query_lmstudio() {
  local model="$1"
  local system="$2"
  local user="$3"

  curl -s http://localhost:1234/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"$model\",
      \"messages\": [
        { \"role\": \"system\", \"content\": \"$system\" },
        { \"role\": \"user\", \"content\": \"$user\" }
      ]
    }"
}