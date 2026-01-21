#!/bin/bash

# Create models directory if it doesn't exist
mkdir -p models
cd models

echo "Downloading models..."

# 1. Diffusion Model (T2I)
if [ ! -f "qwen-image-2512-Q4_K_M.gguf" ]; then
    echo "Downloading Diffusion Model..."
    curl -L -o qwen-image-2512-Q4_K_M.gguf https://huggingface.co/unsloth/Qwen-Image-2512-GGUF/resolve/main/qwen-image-2512-Q4_K_M.gguf
else
    echo "Diffusion Model already exists."
fi

# 2. Text Encoder / LLM
if [ ! -f "Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf" ]; then
    echo "Downloading Text Encoder / LLM..."
    curl -L -o Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf https://huggingface.co/unsloth/Qwen2.5-VL-7B-Instruct-GGUF/resolve/main/Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf
else
    echo "Text Encoder / LLM already exists."
fi

# 3. VAE
if [ ! -f "qwen_image_vae.safetensors" ]; then
    echo "Downloading VAE..."
    curl -L -o qwen_image_vae.safetensors https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors
else
    echo "VAE already exists."
fi

echo "All models downloaded to $(pwd)"
