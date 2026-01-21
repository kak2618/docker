FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    pkg-config \
    curl \
    libgoogle-perftools-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone stable-diffusion.cpp
# Using a specific commit or tag is often safer, but we'll use main as requested
RUN git clone --recursive https://github.com/leejet/stable-diffusion.cpp

# Build stable-diffusion.cpp
WORKDIR /app/stable-diffusion.cpp
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DSD_CUDA=ON && \
    cmake --build . -j$(nproc)

# Make the binary accessible globally (searches in build/ and build/bin/)
RUN find /app/stable-diffusion.cpp/build -name sd-cli -type f -exec ln -s {} /usr/local/bin/sd-cli \;

# Prepare models directory
WORKDIR /app/models

# Download Models
# Note: These are large files. 
# 1. Diffusion Model (T2I)
RUN curl -L -o qwen-image-2512-Q4_K_M.gguf \
    https://huggingface.co/unsloth/Qwen-Image-2512-GGUF/resolve/main/qwen-image-2512-Q4_K_M.gguf

# 2. Text Encoder / LLM
RUN curl -L -o Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf \
    https://huggingface.co/unsloth/Qwen2.5-VL-7B-Instruct-GGUF/resolve/main/Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf

# 3. VAE
RUN curl -L -o qwen_image_vae.safetensors \
    https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors

# Optional: Edit Model (Uncomment if needed, was in original script but not used in final command)
# RUN curl -L -o qwen-image-edit-2511-Q4_K_M.gguf \
#   https://huggingface.co/unsloth/Qwen-Image-Edit-2511-GGUF/resolve/main/qwen-image-edit-2511-Q4_K_M.gguf

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Create output directory
RUN mkdir /output

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
