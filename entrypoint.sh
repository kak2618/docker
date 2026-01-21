#!/bin/bash
set -e

# Default values
PROMPT="$1"
OUTPUT_DIR="/output"
STEPS=50
CFG_SCALE=4.0
HEIGHT=720
WIDTH=1280

if [ -z "$PROMPT" ]; then
    echo "Usage: docker run <image_name> \"Your prompt here\""
    echo "Or set the PROMPT environment variable."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Generate a filename based on timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/output_$TIMESTAMP.png"

echo "Generating image for prompt: $PROMPT"
echo "Output will be saved to: $OUTPUT_FILE"

# Run the generation
sd-cli \
    --diffusion-model /app/models/qwen-image-2512-Q4_K_M.gguf \
    --vae /app/models/qwen_image_vae.safetensors \
    --llm /app/models/Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf \
    --cfg-scale "$CFG_SCALE" \
    --sampling-method euler \
    -v \
    --steps "$STEPS" \
    -H "$HEIGHT" -W "$WIDTH" \
    --diffusion-fa --flow-shift 3 \
    -p "$PROMPT" \
    --clip-on-cpu \
    -o "$OUTPUT_FILE"

echo "Generation complete!"
