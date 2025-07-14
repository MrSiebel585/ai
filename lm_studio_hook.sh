#!/bin/bash

# lm_studio_hook.sh
# A user-friendly shell script to interact with LM Studio's chat API + manage server.

DEFAULT_MODEL="whiterabbitneo-qwen:2"
DEFAULT_SYSTEM="Always answer in rhymes. Today is Thursday"
DEFAULT_USER="What day is it today?"
DEFAULT_TEMPERATURE="0.7"
DEFAULT_MAX_TOKENS="-1"
DEFAULT_STREAM="false"

show_help() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -m MODEL        Model name (default: '$DEFAULT_MODEL')"
  echo "  -s SYSTEM_MSG   System message (default: '$DEFAULT_SYSTEM')"
  echo "  -u USER_MSG     User message (default: '$DEFAULT_USER')"
  echo "  -t TEMPERATURE  Temperature (default: $DEFAULT_TEMPERATURE)"
  echo "  -k MAX_TOKENS   Max tokens (default: $DEFAULT_MAX_TOKENS)"
  echo "  -r STREAM       Stream (true/false) (default: $DEFAULT_STREAM)"
  echo "  -l              Launch LM Studio server (alias: 'lms' command)"
  echo "  -h              Show this help message"
  echo ""
  echo "Example:"
  echo "  $0 -m \"mymodel\" -s \"Be concise.\" -u \"Tell me a joke.\" -t 0.8 -k 100 -r false"
  echo ""
  echo "  To start LM Studio server:"
  echo "  $0 -l"
}

start_lmstudio() {
  echo "Starting LM Studio..."
  if command -v lmstudio &>/dev/null; then
    lmstudio &
    echo "LM Studio launched in background."
  else
    echo "Error: 'lmstudio' command not found in PATH."
    echo "Please install LM Studio CLI or provide its executable in PATH."
    exit 1
  fi
}

# Parse options
while getopts ":m:s:u:t:k:r:lh" opt; do
  case ${opt} in
    m ) MODEL="$OPTARG" ;;
    s ) SYSTEM_MESSAGE="$OPTARG" ;;
    u ) USER_MESSAGE="$OPTARG" ;;
    t ) TEMPERATURE="$OPTARG" ;;
    k ) MAX_TOKENS="$OPTARG" ;;
    r ) STREAM="$OPTARG" ;;
    l )
      start_lmstudio
      exit 0
      ;;
    h )
      show_help
      exit 0
      ;;
    \? )
      echo "Invalid option: -$OPTARG" >&2
      show_help
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument." >&2
      show_help
      exit 1
      ;;
  esac
done

# Set defaults if not provided
MODEL="${MODEL:-$DEFAULT_MODEL}"
SYSTEM_MESSAGE="${SYSTEM_MESSAGE:-$DEFAULT_SYSTEM}"
USER_MESSAGE="${USER_MESSAGE:-$DEFAULT_USER}"
TEMPERATURE="${TEMPERATURE:-$DEFAULT_TEMPERATURE}"
MAX_TOKENS="${MAX_TOKENS:-$DEFAULT_MAX_TOKENS}"
STREAM="${STREAM:-$DEFAULT_STREAM}"

echo "Sending request with:"
echo "  Model:        $MODEL"
echo "  System msg:   $SYSTEM_MESSAGE"
echo "  User msg:     $USER_MESSAGE"
echo "  Temperature:  $TEMPERATURE"
echo "  Max tokens:   $MAX_TOKENS"
echo "  Stream:       $STREAM"
echo ""

curl -s http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [
      { \"role\": \"system\", \"content\": \"$SYSTEM_MESSAGE\" },
      { \"role\": \"user\", \"content\": \"$USER_MESSAGE\" }
    ],
    \"temperature\": $TEMPERATURE,
    \"max_tokens\": $MAX_TOKENS,
    \"stream\": $STREAM
  }"
