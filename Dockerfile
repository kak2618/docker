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

# Models will be mounted from the host.
# See README.md or download_models.sh for instructions on how to get them.

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
