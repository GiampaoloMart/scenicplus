# Start from Micromamba base image
FROM mambaorg/micromamba:1.4.2

# Set environment variables
ENV MAMBA_DOCKERFILE_ACTIVATE=1 \
    MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=$MAMBA_ROOT_PREFIX/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive

# Switch to root for system updates and installations
USER root

# Install system dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        python3-dev \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /scenicplus

# Create conda environment and install dependencies
# Using separate RUN commands to ensure proper execution
COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /tmp/environment.yml

RUN micromamba env create -f /tmp/environment.yml && \
    micromamba clean --all --yes

# Clone and install ScenicPlus
RUN micromamba activate scenicplus && \
    git clone https://github.com/aertslab/scenicplus . && \
    pip install --no-cache-dir .

# Switch back to non-root user for security
USER $MAMBA_USER

# Set the default environment to activate
ENV ENV_NAME=scenicplus

# Keep the container running
CMD ["/bin/bash"]
